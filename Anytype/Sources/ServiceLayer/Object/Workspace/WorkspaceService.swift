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
        let result = Anytype_Rpc.Workspace.Object.ListAdd.Service.invocation(objectIds: objectIds)
            .invoke()
            .getValue(domain: .workspaceService)
        
        return result?.objectIds ?? []
    }
    
    func installObject(objectId: String) -> ObjectDetails? {
        let result = Anytype_Rpc.Workspace.Object.Add.Service.invocation(objectID: objectId)
            .invoke()
            .getValue(domain: .workspaceService)
        
        return result.flatMap { ObjectDetails(protobufStruct: $0.details) }
    }
}
