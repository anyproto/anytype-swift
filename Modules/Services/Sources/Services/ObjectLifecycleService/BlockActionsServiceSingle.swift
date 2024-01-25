import Combine
import ProtobufMessages
import AnytypeCore
import Foundation

public final class ObjectLifecycleService: ObjectLifecycleServiceProtocol {
    
    public init() {}
    
    public func open(contextId: String) async throws -> ObjectViewModel {
        do {
            let result = try await ClientCommands.objectOpen(.with {
                $0.contextID = contextId
                $0.objectID = contextId
            }).invoke()
            return result.objectView
        } catch let error as Anytype_Rpc.Object.Open.Response.Error {
            throw ObjectOpenError(error: error)
        }
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
}
