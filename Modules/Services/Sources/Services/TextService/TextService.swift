import Foundation
import ProtobufMessages

public final class TextService: TextServiceProtocol {
    
    public init() {}
    
    public func setText(contextId: String, blockId: String, middlewareString: MiddlewareString) async throws {
        _ = try await ClientCommands.blockTextSetText(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.text = middlewareString.text
            $0.marks = middlewareString.marks
        }).invoke()
    }

    public func setTextForced(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) async throws {
        _ = try await ClientCommands.blockTextSetText(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.text = middlewareString.text
            $0.marks = middlewareString.marks
        }).invoke()
    }
    
    public func setStyle(contextId: BlockId, blockId: BlockId, style: Style) async throws {
        _ = try await ClientCommands.blockTextSetStyle(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.style = style.asMiddleware
        }).invoke()
    }
    
    public func split(contextId: BlockId, blockId: BlockId, range: NSRange, style: Style, mode: SplitMode) async throws -> BlockId {
        let response = try await ClientCommands.blockSplit(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.range = range.asMiddleware
            $0.style = style.asMiddleware
            $0.mode = mode
        }).invoke()

        return response.blockID
    }

    public func merge(contextId: BlockId, firstBlockId: BlockId, secondBlockId: BlockId) async throws {
        try await ClientCommands.blockMerge(.with {
            $0.contextID = contextId
            $0.firstBlockID = firstBlockId
            $0.secondBlockID = secondBlockId
        }).invoke()
    }
    
    public func checked(contextId: BlockId, blockId: BlockId, newValue: Bool) async throws {
        try await ClientCommands.blockTextSetChecked(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.checked = newValue
        }).invoke()
    }

    public func setTextIcon(
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
