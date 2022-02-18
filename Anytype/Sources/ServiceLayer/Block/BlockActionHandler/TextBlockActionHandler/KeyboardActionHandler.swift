import BlocksModels
import Combine
import AnytypeCore
import Foundation
import ProtobufMessages

protocol KeyboardActionHandlerProtocol {
    func handle(info: BlockInformation, action: CustomTextView.KeyboardAction, newString: NSAttributedString)
}

final class KeyboardActionHandler: KeyboardActionHandlerProtocol {
    
    private let service: BlockActionServiceProtocol

    init(service: BlockActionServiceProtocol) {
        self.service = service
    }

    func handle(info: BlockInformation, action: CustomTextView.KeyboardAction, newString: NSAttributedString) {
        guard case let .text(text) = info.content else {
            anytypeAssertionFailure("Only text block may send keyboard action", domain: .textBlockActionHandler)
            return
        }
        
        switch action {
        case let .enterInsideContent(position):
            service.split(
                newString,
                blockId: info.id,
                mode: info.splitMode,
                position: position,
                newBlockContentType: text.contentType.contentTypeForSplit
            )

        case .enterAtTheBeginingOfContent:
            service.split(
                newString,
                blockId: info.id,
                mode: info.splitMode,
                position: 0,
                newBlockContentType: text.contentType.contentTypeForSplit
            )

        case .enterAtTheEndOfContent:
            onEnterAtTheEndOfContent(info: info, text: text, action: action, newString: newString)

        case .deleteAtTheBeginingOfContent:
            guard text.delitable else { return }
            service.merge(secondBlockId: info.id)

        case .deleteOnEmptyContent:
            service.delete(blockId: info.id)
        }
    }
    
    private func onEnterAtTheEndOfContent(
        info: BlockInformation,
        text: BlockText,
        action: CustomTextView.KeyboardAction,
        newString: NSAttributedString
    ) {
        let enterInEmptyList = text.contentType.isList && newString.string.isEmpty
        guard !enterInEmptyList else {
            service.turnInto(.text, blockId: info.id)
            return
        }
        
        guard text.contentType != .toggle else {
            onEnterAtTheEndOfToggle(info: info, text: text, action: action, newString: newString)
            return
        }
        
        guard let newBlock = BlockBuilder.createInformation(info: info) else { return }
        
        if info.childrenIds.isNotEmpty && text.contentType.isList {
            let firstChildId = info.childrenIds[0]
            service.add(
                info: newBlock,
                targetBlockId: firstChildId,
                position: .top
            )
        } else {
            let type = text.contentType.isList ? text.contentType : .text

            service.split(
                newString,
                blockId: info.id,
                mode: info.splitMode,
                position: newString.string.count,
                newBlockContentType: type
            )
        }
    }
    
    private func onEnterAtTheEndOfToggle(
        info: BlockInformation,
        text: BlockText,
        action: CustomTextView.KeyboardAction,
        newString: NSAttributedString
    ) {
        guard UserSession.shared.isToggled(blockId: info.id) else {
            let type = text.contentType.isList ? text.contentType : .text

            service.split(
                newString,
                blockId: info.id,
                mode: info.splitMode,
                position: newString.string.count,
                newBlockContentType: type
            )
            return
        }
        
        guard let newBlock = BlockBuilder.createInformation(info: info) else { return }
        if info.childrenIds.isEmpty {
            service.addChild(info: newBlock, parentId: info.id)
        } else {
            let firstChildId = info.childrenIds[0]
            service.add(info: newBlock, targetBlockId: firstChildId, position: .top)
        }
    }
}


// MARK: - Extensions
private extension BlockText.Style {
    // We do want to create regular text block when splitting title block
    var contentTypeForSplit: BlockText.Style {
        self == .title ? .text : self
    }
}

private extension BlockInformation {
    var splitMode: Anytype_Rpc.Block.Split.Request.Mode {
        if content.isToggle {
            return UserSession.shared.isToggled(blockId: id) ? .inner : .bottom
        } else {
            return childrenIds.isNotEmpty ? .inner : .bottom
        }
    }
}

private extension BlockText {
    var delitable: Bool {
        contentType != .description
    }
}
