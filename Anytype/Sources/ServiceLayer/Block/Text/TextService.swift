import Foundation
import ProtobufMessages
import Services
import AnytypeCore

final class TextService: TextServiceProtocol {    
    func setText(contextId: String, blockId: String, middlewareString: MiddlewareString) async throws {
        _ = try await ClientCommands.blockTextSetText(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.text = middlewareString.text
            $0.marks = middlewareString.marks
        }).invoke(shouldHandleEvent: false)
        
        await EventsBunch(
            contextId: contextId,
            dataSourceUpdateEvents: [.reload(blockId: blockId)]
        ).send()
    }

    func setTextForced(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) async throws {
        _ = try await ClientCommands.blockTextSetText(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.text = middlewareString.text
            $0.marks = middlewareString.marks
        }).invoke()
    }
    
    func setStyle(contextId: BlockId, blockId: BlockId, style: Style) async throws {
        AnytypeAnalytics.instance().logChangeBlockStyle(style)
        
        _ = try await ClientCommands.blockTextSetStyle(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.style = style.asMiddleware
        }).invoke()
        
        await EventsBunch(
            contextId: contextId,
            localEvents: [.setStyle(blockId: blockId)]
        ).send()
    }
    
    func split(contextId: BlockId, blockId: BlockId, range: NSRange, style: Style, mode: SplitMode) async throws -> BlockId {
        let textContentType = BlockContent.text(.empty(contentType: style)).description
        AnytypeAnalytics.instance().logCreateBlock(type: textContentType, style: String(describing: style))

        let response = try await ClientCommands.blockSplit(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.range = range.asMiddleware
            $0.style = style.asMiddleware
            $0.mode = mode
        }).invoke()

        await EventsBunch(
            contextId: contextId,
            localEvents: [.general]
        ).send()

        return response.blockID
    }

    func merge(contextId: BlockId, firstBlockId: BlockId, secondBlockId: BlockId) async throws {
        try await ClientCommands.blockMerge(.with {
            $0.contextID = contextId
            $0.firstBlockID = firstBlockId
            $0.secondBlockID = secondBlockId
        }).invoke()
    }
    
    func checked(contextId: BlockId, blockId: BlockId, newValue: Bool) async throws {
        try await ClientCommands.blockTextSetChecked(.with {
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
    ) async throws {
        _ = try await ClientCommands.blockTextSetIcon(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.iconImage = imageHash
            $0.iconEmoji = emojiUnicode
        }).invoke()
    }
    
}
