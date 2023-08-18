import Combine
import ProtobufMessages
import AnytypeCore
import Foundation

public final class BlockActionsServiceSingle: BlockActionsServiceSingleProtocol {
    
    public init() {}
    
    public func open(contextId: String) async throws -> ObjectViewModel {
        let result = try await ClientCommands.objectOpen(.with {
            $0.contextID = contextId
            $0.objectID = contextId
        }).invoke()
        return result.objectView
    }

    public func openForPreview(contextId: String) async throws -> ObjectViewModel {
        let result = try await ClientCommands.objectShow(.with {
            $0.contextID = contextId
            $0.objectID = contextId
        }).invoke()
        return result.objectView
    }
    
    public func close(contextId: String) async throws {
        try await ClientCommands.objectClose(.with {
            $0.contextID = contextId
            $0.objectID = contextId
        }).invoke()
    }
    
    public func add(contextId: String, targetId: BlockId, info: BlockInformation, position: BlockPosition) async throws -> BlockId? {
        guard let block = BlockInformationConverter.convert(information: info) else {
            anytypeAssertionFailure("addActionBlockIsNotParsed")
            return nil
        }

        let response = try await ClientCommands.blockCreate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.block = block
            $0.position = position.asMiddleware
        }).invoke()
        
        return response.blockID
    }
    
    public func delete(contextId: String, blockIds: [BlockId]) async throws {        
        try await ClientCommands.blockListDelete(.with {
            $0.contextID = contextId
            $0.blockIds = blockIds
        }).invoke()
    }

    public func duplicate(contextId: String, targetId: BlockId, blockIds: [BlockId], position: BlockPosition) async throws {
        try await ClientCommands.blockListDuplicate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.blockIds = blockIds
            $0.position = position.asMiddleware
        }).invoke()
    }

    public func move(
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
    }
}
