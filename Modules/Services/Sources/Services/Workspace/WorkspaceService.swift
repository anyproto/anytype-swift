import Foundation
import ProtobufMessages

public protocol WorkspaceServiceProtocol {
    func installObjects(objectIds: [String]) async throws -> [String]
    func installObject(objectId: String) async throws -> ObjectDetails?
}

public final class WorkspaceService: WorkspaceServiceProtocol {
    
    public init() {}
    
    // MARK: - WorkspaceServiceProtocol
    
    public func installObjects(objectIds: [String]) async throws -> [String] {
        try await ClientCommands.workspaceObjectListAdd(.with {
            $0.objectIds = objectIds
		}).invoke()
			.objectIds
    }
    
    public func installObject(objectId: String) async throws -> ObjectDetails? {
        let result = try await ClientCommands.workspaceObjectAdd(.with {
            $0.objectID = objectId
        }).invoke()
        
		return try ObjectDetails(protobufStruct: result.details)
    }
}
