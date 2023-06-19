import Foundation
import ProtobufMessages
import Services
import AnytypeCore

final class TextService: TextServiceProtocol {    
    func setText(contextId: String, blockId: String, middlewareString: MiddlewareString) {
        _ = try? ClientCommands.blockTextSetText(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.text = middlewareString.text
            $0.marks = middlewareString.marks
        }).invoke()
    }

    func setTextForced(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) {
        _ = try? ClientCommands.blockTextSetText(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.text = middlewareString.text
            $0.marks = middlewareString.marks
        }).invoke()
    }
    
    func setStyle(contextId: BlockId, blockId: BlockId, style: Style) {
        AnytypeAnalytics.instance().logChangeBlockStyle(style)
        
        _ = try? ClientCommands.blockTextSetStyle(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.style = style.asMiddleware
        }).invoke()
        
        EventsBunch(
            contextId: contextId,
            localEvents: [.setStyle(blockId: blockId)]
        ).send()
    }
    
    func split(contextId: BlockId, blockId: BlockId, range: NSRange, style: Style, mode: SplitMode) -> BlockId? {
        let textContentType = BlockContent.text(.empty(contentType: style)).description
        AnytypeAnalytics.instance().logCreateBlock(type: textContentType, style: String(describing: style))

        let response = try? ClientCommands.blockSplit(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.range = range.asMiddleware
            $0.style = style.asMiddleware
            $0.mode = mode
        }).invoke()

        guard let response else { return nil }
        
        EventsBunch(
            contextId: contextId,
            localEvents: [.general]
        ).send()

        return response.blockID
    }

    func merge(contextId: BlockId, firstBlockId: BlockId, secondBlockId: BlockId) -> Bool {
        let response = try? ClientCommands.blockMerge(.with {
            $0.contextID = contextId
            $0.firstBlockID = firstBlockId
            $0.secondBlockID = secondBlockId
        }).invoke()
        
        return response.isNotNil
    }
    
    func checked(contextId: BlockId, blockId: BlockId, newValue: Bool) {
        _ = try? ClientCommands.blockTextSetChecked(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.checked = newValue
        }).invoke()
    }

    func setTextIcon(
        contextId: BlockId,
        blockId: BlockId,
        imageHash: String,
        emojiUnicode: String
    ) {
        _ = try? ClientCommands.blockTextSetIcon(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.iconImage = imageHash
            $0.iconEmoji = emojiUnicode
        }).invoke()
    }
    
}
