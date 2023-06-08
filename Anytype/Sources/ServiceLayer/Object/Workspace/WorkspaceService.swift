import Foundation
import BlocksModels
import ProtobufMessages

protocol WorkspaceServiceProtocol {
    func installObjects(objectIds: [String]) -> [String]
    func installObject(objectId: String) -> ObjectDetails?
}

final class WorkspaceService: WorkspaceServiceProtocol {
    
    // MARK: - WorkspaceServiceProtocol
    
    func installObjects(objectIds: [String]) -> [String] {
        let result = try? ClientCommands.workspaceObjectListAdd(.with {
            $0.objectIds = objectIds
        }).invoke(errorDomain: .workspaceService)
        
        return result?.objectIds ?? []
    }
    
    func installObject(objectId: String) -> ObjectDetails? {
        let result = try? ClientCommands.workspaceObjectAdd(.with {
            $0.objectID = objectId
        }).invoke(errorDomain: .workspaceService)
        
        return result.flatMap { ObjectDetails(protobufStruct: $0.details) }
    }
}
