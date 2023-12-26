import Services
import Combine
import AnytypeCore
import Foundation
import ProtobufMessages

protocol KeyboardActionHandlerProtocol {
    func handle(info: BlockInformation, currentString: NSAttributedString, action: CustomTextView.KeyboardAction)
}

final class KeyboardActionHandler: KeyboardActionHandlerProtocol {
    
    private let documentId: String
    private let service: BlockActionServiceProtocol
    private let listService: BlockListServiceProtocol
    private let toggleStorage: ToggleStorage
    private let container: InfoContainerProtocol
    private weak var modelsHolder: EditorMainItemModelsHolder?
    
    init(
        documentId: String,
        service: BlockActionServiceProtocol,
        listService: BlockListServiceProtocol,
        toggleStorage: ToggleStorage,
        container: InfoContainerProtocol,
        modelsHolder: EditorMainItemModelsHolder
    ) {
        self.documentId = documentId
        self.service = service
        self.listService = listService
        self.toggleStorage = toggleStorage
        self.container = container
        self.modelsHolder = modelsHolder
    }

    func handle(info: BlockInformation, currentString: NSAttributedString, action: CustomTextView.KeyboardAction) {
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
                service.turnInto(.text, blockId: info.id)
                logChangeBlockTextStyle()
                return
            }
            
            if info.childrenIds.isNotEmpty {
                service.add(info: .emptyText, targetBlockId: info.id, position: .top, setFocus: false)
            } else {
                service.split(
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
            service.split(
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
                enterForEmpty(text: text, info: info)
                return
            }
            onEnterAtTheEndOfContent(info: info, text: text, range: range, action: action, newString: string)
            
        case let .enterAtTheBegining(_, range):
            service.split(currentString, blockId: info.id, mode: .bottom, range: range, newBlockContentType: text.contentType)
            logCreateBlock(with: text.contentType)
        case .delete:
            Task {
                await onDelete(text: text, info: info, parent: parent)
            }
        }
    }
    
    @MainActor
    private func onDelete(text: BlockText, info: BlockInformation, parent: BlockInformation) async {
        if text.contentType.isList || text.contentType == .quote || text.contentType == .callout {
            service.turnInto(.text, blockId: info.id)
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
            try? await listService.move(objectId: documentId, blockId: info.id, targetId: parent.id, position: .bottom)
            return
        }
        
        service.merge(secondBlockId: info.id)
    }
    
    private func enterForEmpty(text: BlockText, info: BlockInformation) {
        if text.contentType != .text {
            service.turnInto(.text, blockId: info.id)
            logChangeBlockTextStyle()
            return
        }
        
        service.add(info: .emptyText, targetBlockId: info.id, position: .top, setFocus: false)
    }
    
    private func onEnterAtTheEndOfContent(
        info: BlockInformation,
        text: BlockText,
        range: NSRange,
        action: CustomTextView.KeyboardAction,
        newString: NSAttributedString
    ) {
        let needChildForToggle = text.contentType == .toggle && toggleStorage.isToggled(blockId: info.id)
        let needChildForList = text.contentType != .toggle && text.contentType.isList && info.childrenIds.isNotEmpty
        
        if needChildForToggle {
            if info.childrenIds.isEmpty {
                service.addChild(info: BlockInformation.emptyText, parentId: info.id)
            } else {
                let firstChildId = info.childrenIds[0]
                service.add(info: BlockInformation.emptyText, targetBlockId: firstChildId, position: .top)
            }
        } else if needChildForList {
            let firstChildId = info.childrenIds[0]
            service.add(
                info: BlockInformation.emptyText,
                targetBlockId: firstChildId,
                position: .top
            )
        } else {
            let type = text.contentType.isList ? text.contentType : .text

            service.split(
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
        AnytypeAnalytics.instance().logCreateBlock(type: textContentType, style: String(describing: style))
    }
}


// MARK: - Extensions
private extension KeyboardActionHandler {
    // We do want to create regular text block when splitting title block
    func contentTypeForSplit(_ style: BlockText.Style, blockId: BlockId) -> BlockText.Style {
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
