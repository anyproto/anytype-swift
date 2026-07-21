import Foundation
import Services

final class TextServiceHandler: TextServiceProtocol {
    
    private let textService: any TextServiceProtocol = Container.shared.textService()
    
    func setText(contextId: String, blockId: String, middlewareString: MiddlewareString) async throws {
        try await textService.setText(contextId: contextId, blockId: blockId, middlewareString: middlewareString)
    }

    func setTextForced(contextId: String, blockId: String, middlewareString: MiddlewareString) async throws {
        try await textService.setTextForced(contextId: contextId, blockId: blockId, middlewareString: middlewareString)
    }
    
    func setStyle(contextId: String, blockId: String, style: Style) async throws {
        try await textService.setStyle(contextId: contextId, blockId: blockId, style: style)
        
        await EventsBunch(
            contextId: contextId,
            localEvents: [.setStyle(blockId: blockId)]
        ).send()
    }
    
    func split(contextId: String, blockId: String, range: NSRange, style: Style, mode: SplitMode) async throws -> String {
        // No local events here: the render pass they trigger must only run after the caller
        // (setAndSplit) has recorded the unanimated-arrival registration and the focus intent
        // for the created block — see BlockActionService.setAndSplit.
        try await textService.split(contextId: contextId, blockId: blockId, range: range, style: style, mode: mode)
    }

    func merge(contextId: String, firstBlockId: String, secondBlockId: String) async throws {
        try await textService.merge(contextId: contextId, firstBlockId: firstBlockId, secondBlockId: secondBlockId)
    }
    
    func checked(contextId: String, blockId: String, newValue: Bool) async throws {
        try await textService.checked(contextId: contextId, blockId: blockId, newValue: newValue)
    }

    func setTextIcon(
        contextId: String,
        blockId: String,
        imageObjectId: String,
        emojiUnicode: String
    ) async throws {
        try await textService.setTextIcon(contextId: contextId, blockId: blockId, imageObjectId: imageObjectId, emojiUnicode: emojiUnicode)
    }
}
