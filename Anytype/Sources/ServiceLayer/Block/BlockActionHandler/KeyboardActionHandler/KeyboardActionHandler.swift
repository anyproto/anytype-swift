import Services
import Combine
import AnytypeCore
import UIKit
import ProtobufMessages

@MainActor
protocol KeyboardActionHandlerProtocol {
    func handle(
        info: BlockInformation,
        textView: UITextView,
        action: CustomTextView.KeyboardAction
    ) async throws
}

@MainActor
final class KeyboardActionHandler: KeyboardActionHandlerProtocol {
    private let documentId: String
    private let spaceId: String
    private let service: BlockActionServiceProtocol
    private let blockService: BlockServiceProtocol
    private let toggleStorage: ToggleStorage
    private let container: InfoContainerProtocol
    private weak var modelsHolder: EditorMainItemModelsHolder?
    private let editorCollectionController: EditorBlockCollectionController
    
    nonisolated init(
        documentId: String,
        spaceId: String,
        service: BlockActionServiceProtocol,
        blockService: BlockServiceProtocol,
        toggleStorage: ToggleStorage,
        container: InfoContainerProtocol,
        modelsHolder: EditorMainItemModelsHolder,
        editorCollectionController: EditorBlockCollectionController
    ) {
        self.documentId = documentId
        self.spaceId = spaceId
        self.service = service
        self.blockService = blockService
        self.toggleStorage = toggleStorage
        self.container = container
        self.modelsHolder = modelsHolder
        self.editorCollectionController = editorCollectionController
    }

    func handle(
        info: BlockInformation,
        textView: UITextView,
        action: CustomTextView.KeyboardAction
    ) async throws {
        guard case let .text(text) = info.content else {
            anytypeAssertionFailure("Only text block may send keyboard action")
            return
        }
        guard let parentId = info.configurationData.parentId,
              let parent = container.get(id: parentId)
        else {
            anytypeAssertionFailure("No parent for text")
            return
        }
        
        switch action {
        case .enterForEmpty:
            if text.contentType.isList {
                try await service.turnInto(.text, blockId: info.id)
                logChangeBlockTextStyle()
                return
            }
            
            if info.childrenIds.isNotEmpty {
                try await service.add(info: .emptyText, targetBlockId: info.id, position: .top, setFocus: false)
            } else {
                try await service.split(
                    .init(string: ""),
                    blockId: info.id,
                    mode: .bottom,
                    range: NSRange(location: 0, length: 0),
                    newBlockContentType: .text
                )
                logCreateBlock(with: .text)
            }
        case let .enterInside(string, range):

            let newBlockContentType = contentTypeForSplit(text.contentType, blockId: info.id)

            try await service.split(
                string,
                blockId: info.id,
                mode: splitMode(info),
                range: range,
                newBlockContentType: newBlockContentType
            )

            logCreateBlock(with: newBlockContentType)
        case let .enterAtTheEnd(string, range):
            guard string.string.isNotEmpty else {
                anytypeAssertionFailure("Empty sting in enterAtTheEnd")
                try await enterForEmpty(text: text, info: info)
                return
            }
            try await onEnterAtTheEndOfContent(info: info, text: text, range: range, action: action, newString: string)
            editorCollectionController.scrollToTextViewIfNotVisible(textView: textView)
        case .enterAtTheBegining:
            try await service.add(
                info: .empty(content: .text(.empty(contentType: text.contentType))),
                targetBlockId: info.id,
                position: .top,
                setFocus: false
            )
            
            editorCollectionController.scrollToTextViewIfNotVisible(textView: textView)
        case .delete:
            try await onDelete(text: text, info: info, parent: parent, textView: textView)
        }
    }
    
    private func onDelete(text: BlockText, info: BlockInformation, parent: BlockInformation, textView: UITextView) async throws {
        if text.contentType.isList || text.contentType == .quote || text.contentType == .callout {
            try await service.turnInto(.text, blockId: info.id)
            logChangeBlockTextStyle()
            return
        }
        
        guard isBlockDelitable(info: info, text: text, parent: parent) else {

            let model = modelsHolder?.findModel(beforeBlockId: info.id, acceptingTypes: BlockContentType.allTextTypes)

            model?.set(focus: .end)
            return
        }
        
        if isLastChildOfBlock(info: info, container: container, parent: parent)
        {
            // on delete of last child of block - move child to parent level
            try? await blockService.move(objectId: documentId, blockId: info.id, targetId: parent.id, position: .bottom)
            return
        }
        defer {
            editorCollectionController.scrollToTextViewIfNotVisible(textView: textView)
        }
        
        let model = modelsHolder?.findModel(beforeBlockId: info.id, acceptingTypes: BlockContentType.allTextTypes)
        
        if let model, model.info.isTextAndEmpty { // Preventing weird animation when previous block is empty
            service.delete(blockIds: [model.info.id])
            return
        }
        
        // Previous block
        // If content -> merge previous block content + current content.
        try await service.merge(secondBlockId: info.id)
    }
    
    private func enterForEmpty(text: BlockText, info: BlockInformation) async throws {
        if text.contentType != .text {
            try await service.turnInto(.text, blockId: info.id)
            logChangeBlockTextStyle()
            return
        }
        
        try await service.add(info: .emptyText, targetBlockId: info.id, position: .top, setFocus: false)
    }
    
    private func onEnterAtTheEndOfContent(
        info: BlockInformation,
        text: BlockText,
        range: NSRange,
        action: CustomTextView.KeyboardAction,
        newString: NSAttributedString
    ) async throws {
        let needChildForToggle = text.contentType == .toggle && toggleStorage.isToggled(blockId: info.id)
        let needChildForList = text.contentType != .toggle && text.contentType.isList && info.childrenIds.isNotEmpty
        
        if needChildForToggle {
            if info.childrenIds.isEmpty {
                try await service.addChild(info: BlockInformation.emptyText, parentId: info.id)
            } else {
                let firstChildId = info.childrenIds[0]
                try await service.add(info: BlockInformation.emptyText, targetBlockId: firstChildId, position: .top)
            }
        } else if needChildForList {
            let firstChildId = info.childrenIds[0]
            try await service.add(
                info: BlockInformation.emptyText,
                targetBlockId: firstChildId,
                position: .top
            )
        } else {
            let type = text.contentType.isList ? text.contentType : .text

            try await service.split(
                newString,
                blockId: info.id,
                mode: splitMode(info),
                range: range,
                newBlockContentType: type
            )
            logCreateBlock(with: type)
        }
    }
    
    private func logChangeBlockTextStyle() {
        AnytypeAnalytics.instance().logChangeBlockStyle(.text)
    }
    
    private func logCreateBlock(with style: BlockText.Style) {
        let textContentType = BlockContent.text(.empty(contentType: style)).type.analyticsValue
        AnytypeAnalytics.instance().logCreateBlock(type: textContentType, spaceId: spaceId, style: String(describing: style))
    }
}


// MARK: - Extensions
private extension KeyboardActionHandler {
    // We do want to create regular text block when splitting title block
    func contentTypeForSplit(_ style: BlockText.Style, blockId: String) -> BlockText.Style {
        if style == .title || style == .description {
            return .text
        }
        
        if style == .toggle {
            return toggleStorage.isToggled(blockId: blockId) ? .text : .toggle
        }
        
        return style
    }

    func splitMode(_ info: BlockInformation) -> Anytype_Rpc.Block.Split.Request.Mode {
        if info.content.isToggle {
            return toggleStorage.isToggled(blockId: info.id) ? .inner : .bottom
        } else {
            return info.childrenIds.isNotEmpty ? .inner : .bottom
        }
    }
    
    
    func isBlockDelitable(info: BlockInformation, text: BlockText, parent: BlockInformation) -> Bool {
        if text.contentType == .title || text.contentType == .description {

            return false
        }
        
        guard let header = parent.headerLayout(container: container) else {
            // if header is nil - we are in nested blocks
            return true
        }
        
        guard let firstTextBlock = container.children(of: parent.id).first(where: { $0.isText }) else {
            return false
        }
        
        let isFirstBlock = info.id == firstTextBlock.id
        let headerHaveTextBlocks = container.children(of: header.id).contains { $0.isText }
        if isFirstBlock && !headerHaveTextBlocks {
            return false // We can delete block only if there is text block in header to set focus
        }
        
        return true
    }
    
    
    func isLastChildOfBlock(info: BlockInformation, container: InfoContainerProtocol, parent: BlockInformation) -> Bool {
        let children = container.children(of: parent.id)
        let isLastChid = children.last?.id == info.id
        let isParentTypeBlock = parent.kind == .block
        
        return isLastChid && isParentTypeBlock
    }
}
