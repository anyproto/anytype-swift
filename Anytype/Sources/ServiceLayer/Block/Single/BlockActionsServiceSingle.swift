import Combine
import Services
import ProtobufMessages
import AnytypeCore
import Foundation

// MARK: Actions
final class BlockActionsServiceSingle: BlockActionsServiceSingleProtocol {
    
    func open(contextId: String) async throws -> ObjectViewModel {
        let result = try await ClientCommands.objectOpen(.with {
            $0.contextID = contextId
            $0.objectID = contextId
        }).invoke()
        return result.objectView
    }

    func openForPreview(contextId: String) async throws -> ObjectViewModel {
        let result = try await ClientCommands.objectShow(.with {
            $0.contextID = contextId
            $0.objectID = contextId
        }).invoke()
        return result.objectView
    }
    
    func close(contextId: String) async throws {
        try await ClientCommands.objectClose(.with {
            $0.contextID = contextId
            $0.objectID = contextId
        }).invoke()
    }
    
    func add(contextId: String, targetId: BlockId, info: BlockInformation, position: BlockPosition) async throws -> BlockId? {
        guard let block = BlockInformationConverter.convert(information: info) else {
            anytypeAssertionFailure("addActionBlockIsNotParsed")
            return nil
        }

        AnytypeAnalytics.instance().logCreateBlock(type: info.content.description, style: info.content.type.style)

        let response = try await ClientCommands.blockCreate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.block = block
            $0.position = position.asMiddleware
        }).invoke()
        
        return response.blockID
    }
    
    func delete(contextId: String, blockIds: [BlockId]) async throws {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.blockDelete)
        
        try await ClientCommands.blockListDelete(.with {
            $0.contextID = contextId
            $0.blockIds = blockIds
        }).invoke()
    }

    func duplicate(contextId: String, targetId: BlockId, blockIds: [BlockId], position: BlockPosition) async throws {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.blockListDuplicate)
        
        try await ClientCommands.blockListDuplicate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.blockIds = blockIds
            $0.position = position.asMiddleware
        }).invoke()
    }

    func move(
        contextId: String,
        blockIds: [String],
        targetContextID: BlockId,
        dropTargetID: String,
        position: BlockPosition
    ) async throws {
        try await ClientCommands.blockListMoveToExistingObject(.with {
            $0.contextID = contextId
            $0.blockIds = blockIds
            $0.targetContextID = targetContextID
            $0.dropTargetID = dropTargetID
            $0.position = position.asMiddleware
        }).invoke()
        
        AnytypeAnalytics.instance().logReorderBlock(count: blockIds.count)
    }
}
