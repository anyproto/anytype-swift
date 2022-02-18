import BlocksModels
import Combine
import AnytypeCore
import Foundation

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
            let type = text.contentType.contentTypeForSplit
            service.split(info: info, position: position, newBlockContentType: type, attributedString: newString)
            
        case let .enterAtTheBeginingOfContent(payload):
            guard payload.isNotEmpty else {
                #warning("Fix it in TextView API.")
                /// If payload is empty, so, handle it as .enter ( or .enter at the end )
                handle(info: info, action: .enterAtTheEndOfContent, newString: newString)
                return
            }

            let type = text.contentType.contentTypeForSplit
            service.split(info: info, position: 0, newBlockContentType: type, attributedString: newString)

        case .enterAtTheEndOfContent:
            onEnterAtTheEndOfContent(info: info, text: text, action: action, newString: newString)

        case .deleteAtTheBeginingOfContent:
            guard text.contentType != .description else { return }

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
                info: info,
                position: newString.string.count,
                newBlockContentType: type,
                attributedString: newString
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
                info: info,
                position: newString.string.count,
                newBlockContentType: type,
                attributedString: newString
            )
            return
        }
        
        guard let newBlock = BlockBuilder.createInformation(info: info) else { return }
        if info.childrenIds.isEmpty {
            service.addChild(info: newBlock, parentId: info.id)
        } else {
            let firstChildId = info.childrenIds[0]
            service.add(
                info: newBlock,
                targetBlockId: firstChildId,
                position: .top
            )
        }
    }
}

extension BlockText.Style {
    // We do want to create regular text block when splitting title block
    var contentTypeForSplit: BlockText.Style {
        self == .title ? .text : self
    }
}
