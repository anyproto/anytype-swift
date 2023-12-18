import Foundation
import Services

final class TextServiceHandler: TextServiceProtocol {
    
    private let textService: TextServiceProtocol
    
    init(textService: TextServiceProtocol) {
        self.textService = textService
    }
    
    func setText(contextId: String, blockId: String, middlewareString: MiddlewareString) async throws {
        try await textService.setText(contextId: contextId, blockId: blockId, middlewareString: middlewareString)
    }

    func setTextForced(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) async throws {
        try await textService.setTextForced(contextId: contextId, blockId: blockId, middlewareString: middlewareString)
    }
    
    func setStyle(contextId: BlockId, blockId: BlockId, style: Style) async throws {
        try await textService.setStyle(contextId: contextId, blockId: blockId, style: style)
        
        await EventsBunch(
            contextId: contextId,
            localEvents: [.setStyle(blockId: blockId)]
        ).send()
    }
    
    func split(contextId: BlockId, blockId: BlockId, range: NSRange, style: Style, mode: SplitMode) async throws -> BlockId {
        let blockID = try await textService.split(contextId: contextId, blockId: blockId, range: range, style: style, mode: mode)
        
        await EventsBunch(
            contextId: contextId,
            localEvents: [.general]
        ).send()

        return blockID
    }

    func merge(contextId: BlockId, firstBlockId: BlockId, secondBlockId: BlockId) async throws {
        try await textService.merge(contextId: contextId, firstBlockId: firstBlockId, secondBlockId: secondBlockId)
    }
    
    func checked(contextId: BlockId, blockId: BlockId, newValue: Bool) async throws {
        try await textService.checked(contextId: contextId, blockId: blockId, newValue: newValue)
    }

    func setTextIcon(
        contextId: BlockId,
        blockId: BlockId,
        imageHash: String,
        emojiUnicode: String
    ) async throws {
        try await textService.setTextIcon(contextId: contextId, blockId: blockId, imageHash: imageHash, emojiUnicode: emojiUnicode)
    }
}
