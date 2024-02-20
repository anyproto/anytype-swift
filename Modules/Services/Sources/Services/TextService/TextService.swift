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

    public func setTextForced(contextId: String, blockId: String, middlewareString: MiddlewareString) async throws {
        _ = try await ClientCommands.blockTextSetText(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.text = middlewareString.text
            $0.marks = middlewareString.marks
        }).invoke()
    }
    
    public func setStyle(contextId: String, blockId: String, style: Style) async throws {
        _ = try await ClientCommands.blockTextSetStyle(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.style = style.asMiddleware
        }).invoke()
    }
    
    public func split(contextId: String, blockId: String, range: NSRange, style: Style, mode: SplitMode) async throws -> String {
        let response = try await ClientCommands.blockSplit(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.range = range.asMiddleware
            $0.style = style.asMiddleware
            $0.mode = mode
        }).invoke()

        return response.blockID
    }

    public func merge(contextId: String, firstBlockId: String, secondBlockId: String) async throws {
        try await ClientCommands.blockMerge(.with {
            $0.contextID = contextId
            $0.firstBlockID = firstBlockId
            $0.secondBlockID = secondBlockId
        }).invoke()
    }
    
    public func checked(contextId: String, blockId: String, newValue: Bool) async throws {
        try await ClientCommands.blockTextSetChecked(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.checked = newValue
        }).invoke()
    }

    public func setTextIcon(
        contextId: String,
        blockId: String,
        imageObjectId: String,
        emojiUnicode: String
    ) async throws {
        _ = try await ClientCommands.blockTextSetIcon(.with {
            $0.contextID = contextId
            $0.blockID = blockId
            $0.iconImage = imageObjectId
            $0.iconEmoji = emojiUnicode
        }).invoke()
    }
    
}
