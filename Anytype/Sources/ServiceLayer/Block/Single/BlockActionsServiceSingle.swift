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
        }).invoke(errorDomain: .blockActionsService)
        return result.objectView
    }

    func openForPreview(contextId: String) async throws -> ObjectViewModel {
        let result = try await ClientCommands.objectShow(.with {
            $0.contextID = contextId
            $0.objectID = contextId
        }).invoke(errorDomain: .blockActionsService)
        return result.objectView
    }
    
    func close(contextId: String) async throws {
        try await ClientCommands.objectClose(.with {
            $0.contextID = contextId
            $0.objectID = contextId
        }).invoke(errorDomain: .blockActionsService)
    }
    
    func add(contextId: String, targetId: BlockId, info: BlockInformation, position: BlockPosition) -> BlockId? {
        guard let block = BlockInformationConverter.convert(information: info) else {
            anytypeAssertionFailure("addActionBlockIsNotParsed", domain: .blockActionsService)
            return nil
        }

        AnytypeAnalytics.instance().logCreateBlock(type: info.content.description, style: info.content.type.style)

        let response = try? ClientCommands.blockCreate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.block = block
            $0.position = position.asMiddleware
        })
        .invoke(errorDomain: .blockActionsService)
        
        return response?.blockID
    }
    
    func delete(contextId: String, blockIds: [BlockId]) -> Bool {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.blockDelete)
        
        _ = try? ClientCommands.blockListDelete(.with {
            $0.contextID = contextId
            $0.blockIds = blockIds
        })
        .invoke(errorDomain: .blockActionsService)
        
        return true
    }

    func duplicate(contextId: String, targetId: BlockId, blockIds: [BlockId], position: BlockPosition) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.blockListDuplicate)
        
        _ = try? ClientCommands.blockListDuplicate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.blockIds = blockIds
            $0.position = position.asMiddleware
        })
        .invoke(errorDomain: .blockActionsService)
    }

    func move(
        contextId: String,
        blockIds: [String],
        targetContextID: BlockId,
        dropTargetID: String,
        position: BlockPosition
    ) {
        _ = try? ClientCommands.blockListMoveToExistingObject(.with {
            $0.contextID = contextId
            $0.blockIds = blockIds
            $0.targetContextID = targetContextID
            $0.dropTargetID = dropTargetID
            $0.position = position.asMiddleware
        })
        .invoke(errorDomain: .blockActionsService)
        
        AnytypeAnalytics.instance().logReorderBlock(count: blockIds.count)
    }
}
