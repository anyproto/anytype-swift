import BlocksModels
import Combine
import AnytypeCore
import Foundation
import ProtobufMessages

protocol KeyboardActionHandlerProtocol {
    func handle(info: BlockInformation, currentString: NSAttributedString, action: CustomTextView.KeyboardAction)
}

final class KeyboardActionHandler: KeyboardActionHandlerProtocol {
    
    private let service: BlockActionServiceProtocol
    private let listService: BlockListServiceProtocol
    private let toggleStorage: ToggleStorage
    private let container: InfoContainerProtocol
    private let modelsHolder: EditorMainItemModelsHolder
    
    init(
        service: BlockActionServiceProtocol,
        listService: BlockListServiceProtocol,
        toggleStorage: ToggleStorage,
        container: InfoContainerProtocol,
        modelsHolder: EditorMainItemModelsHolder
    ) {
        self.service = service
        self.listService = listService
        self.toggleStorage = toggleStorage
        self.container = container
        self.modelsHolder = modelsHolder
    }

    func handle(info: BlockInformation, currentString: NSAttributedString, action: CustomTextView.KeyboardAction) {
        guard case let .text(text) = info.content else {
            anytypeAssertionFailure("Only text block may send keyboard action", domain: .keyboardActionHandler)
            return
        }
        guard let parentId = info.configurationData.parentId,
              let parent = container.get(id: parentId)
        else {
            anytypeAssertionFailure("No parent in \(text)", domain: .keyboardActionHandler)
            return
        }
        
        switch action {
        case .enterForEmpty:
            if text.contentType.isList {
                service.turnInto(.text, blockId: info.id.value)
                return
            }
            
            if info.childrenIds.isNotEmpty {
                service.add(info: .emptyText, targetBlockId: info.id.value, position: .top, setFocus: false)
            } else {
                service.split(
                    .init(string: ""),
                    blockId: info.id.value,
                    mode: .bottom,
                    nsRange: NSRange(location: 0, length: 0),
                    newBlockContentType: .text
                )
            }
        case let .enterInside(string, nsRange):
            service.split(
                string,
                blockId: info.id.value,
                mode: splitMode(info),
                nsRange: nsRange,
                newBlockContentType: contentTypeForSplit(text.contentType, blockId: info.id.value)
            )

        case let .enterAtTheEnd(string, nsRange):
            guard string.string.isNotEmpty else {
                anytypeAssertionFailure("Empty sting in enterAtTheEnd", domain: .keyboardActionHandler)
                enterForEmpty(text: text, info: info)
                return
            }
            onEnterAtTheEndOfContent(info: info, text: text, nsRange: nsRange, action: action, newString: string)
            
        case let .enterAtTheBegining(_, nsRange):
            service.split(currentString, blockId: info.id.value, mode: .bottom, nsRange: nsRange, newBlockContentType: .text)
        case .delete:
            onDelete(text: text, info: info, parent: parent)
        }
    }
    
    private func onDelete(text: BlockText, info: BlockInformation, parent: BlockInformation) {
        if text.contentType.isList {
            service.turnInto(.text, blockId: info.id.value)
            return
        }
        
        guard isBlockDelitable(info: info, text: text, parent: parent) else {
            modelsHolder
                .findModel(
                    beforeBlockId: info.id.value,
                    acceptingTypes: BlockContentType.allTextTypes
                )?
                .set(focus: .end)
            return
        }
        
        if isLastChildOfBlock(info: info, container: container, parent: parent)
        {
            // on delete of last child of block - move child to parent level
            listService.move(blockId: info.id.value, targetId: parent.id.value, position: .bottom)
            return
        }
        
        service.merge(secondBlockId: info.id.value)
    }
    
    private func enterForEmpty(text: BlockText, info: BlockInformation) {
        if text.contentType != .text {
            service.turnInto(.text, blockId: info.id.value)
            return
        }
        
        service.add(info: .emptyText, targetBlockId: info.id.value, position: .top, setFocus: false)
    }
    
    private func onEnterAtTheEndOfContent(
        info: BlockInformation,
        text: BlockText,
        nsRange: NSRange,
        action: CustomTextView.KeyboardAction,
        newString: NSAttributedString
    ) {
        let needChildForToggle = text.contentType == .toggle && toggleStorage.isToggled(blockId: info.id.value)
        let needChildForList = text.contentType != .toggle && text.contentType.isList && info.childrenIds.isNotEmpty
        
        if needChildForToggle {
            if info.childrenIds.isEmpty {
                service.addChild(info: BlockInformation.emptyText, parentId: info.id.value)
            } else {
                let firstChildId = info.childrenIds[0]
                service.add(info: BlockInformation.emptyText, targetBlockId: firstChildId.value, position: .top)
            }
        } else if needChildForList {
            let firstChildId = info.childrenIds[0]
            service.add(
                info: BlockInformation.emptyText,
                targetBlockId: firstChildId.value,
                position: .top
            )
        } else {
            let type = text.contentType.isList ? text.contentType : .text

            service.split(
                newString,
                blockId: info.id.value,
                mode: splitMode(info),
                nsRange: nsRange,
                newBlockContentType: type
            )
        }
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
            return toggleStorage.isToggled(blockId: info.id.value) ? .inner : .bottom
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
        
        guard let firstTextBlock = container.children(of: parent.id.value).first(where: { $0.isText }) else {
            return false
        }
        
        let isFirstBlock = info.id == firstTextBlock.id
        let headerHaveTextBlocks = container.children(of: header.id.value).contains { $0.isText }
        if isFirstBlock && !headerHaveTextBlocks {
            return false // We can delete block only if there is text block in header to set focus
        }
        
        return true
    }
    
    
    func isLastChildOfBlock(info: BlockInformation, container: InfoContainerProtocol, parent: BlockInformation) -> Bool {
        let children = container.children(of: parent.id.value)
        let isLastChid = children.last?.id == info.id
        let isParentTypeBlock = parent.kind == .block
        
        return isLastChid && isParentTypeBlock
    }
}
