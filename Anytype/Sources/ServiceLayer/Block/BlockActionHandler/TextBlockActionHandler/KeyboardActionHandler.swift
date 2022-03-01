import BlocksModels
import Combine
import AnytypeCore
import Foundation
import ProtobufMessages

protocol KeyboardActionHandlerProtocol {
    func handle(info: BlockInformation, action: CustomTextView.KeyboardAction)
}

final class KeyboardActionHandler: KeyboardActionHandlerProtocol {
    
    private let service: BlockActionServiceProtocol
    private let listService: BlockListServiceProtocol
    private let toggleStorage: ToggleStorage
    
    init(
        service: BlockActionServiceProtocol,
        listService: BlockListServiceProtocol,
        toggleStorage: ToggleStorage
    ) {
        self.service = service
        self.listService = listService
        self.toggleStorage = toggleStorage
    }

    func handle(info: BlockInformation, action: CustomTextView.KeyboardAction) {
        guard case let .text(text) = info.content else {
            anytypeAssertionFailure("Only text block may send keyboard action", domain: .keyboardActionHandler)
            return
        }
        
        switch action {
        case .enterForEmpty:
            if text.contentType.isList {
                service.turnInto(.text, blockId: info.id)
                return
            }
            
            if info.childrenIds.isNotEmpty {
                service.add(info: .emptyText, targetBlockId: info.id, position: .top, setFocus: false)
            } else {
                service.split(
                    .init(string: ""),
                    blockId: info.id,
                    mode: .bottom,
                    position: 0,
                    newBlockContentType: .text
                )
            }
        case let .enterInside(string, position):
            service.split(
                string,
                blockId: info.id,
                mode: splitMode(info),
                position: position,
                newBlockContentType: contentTypeForSplit(text.contentType, blockId: info.id)
            )

        case .enterAtTheEnd(let string):
            guard string.string.isNotEmpty else {
                anytypeAssertionFailure("Empty sting in enterAtTheEnd", domain: .keyboardActionHandler)
                enterForEmpty(text: text, info: info)
                return
            }
            onEnterAtTheEndOfContent(info: info, text: text, action: action, newString: string)

        case .deleteAtTheBegining:
            guard text.delitable else { return }
            service.merge(secondBlockId: info.id)

        case .deleteForEmpty:
            if text.contentType.isList {
                service.turnInto(.text, blockId: info.id)
                return
            }
            
            guard text.delitable else { return }
            
            if info.childrenIds.isEmpty {
                service.delete(blockId: info.id)
            } else {
                listService.replace(blockIds: info.childrenIds, targetId: info.id)
            }
        }
    }
    
    private func enterForEmpty(text: BlockText, info: BlockInformation) {
        if text.contentType != .text {
            service.turnInto(.text, blockId: info.id)
            return
        }
        
        service.add(info: .emptyText, targetBlockId: info.id, position: .top, setFocus: false)
    }
    
    private func onEnterAtTheEndOfContent(
        info: BlockInformation,
        text: BlockText,
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
                position: newString.string.count,
                newBlockContentType: type
            )
        }
    }
}


// MARK: - Extensions
private extension KeyboardActionHandler {
    // We do want to create regular text block when splitting title block
    func contentTypeForSplit(_ style: BlockText.Style, blockId: BlockId) -> BlockText.Style {
        if style == .title {
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
}

private extension BlockText {
    var delitable: Bool {
        contentType != .description
    }
}
