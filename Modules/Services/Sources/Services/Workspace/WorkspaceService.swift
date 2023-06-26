import Foundation
import ProtobufMessages

public protocol WorkspaceServiceProtocol {
    func installObjects(objectIds: [String]) -> [String]
    func installObject(objectId: String) -> ObjectDetails?
}

public final class WorkspaceService: WorkspaceServiceProtocol {
    
    public init() {}
    
    // MARK: - WorkspaceServiceProtocol
    
    public func installObjects(objectIds: [String]) -> [String] {
        let result = try? ClientCommands.workspaceObjectListAdd(.with {
            $0.objectIds = objectIds
        }).invoke()
        
        return result?.objectIds ?? []
    }
    
    public func installObject(objectId: String) -> ObjectDetails? {
        let result = try? ClientCommands.workspaceObjectAdd(.with {
            $0.objectID = objectId
        }).invoke()
        
        return result.flatMap { try? ObjectDetails(protobufStruct: $0.details) }
    }
}
