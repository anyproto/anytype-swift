import Foundation
import BlocksModels
import ProtobufMessages

protocol WorkspaceServiceProtocol {
    func installObjects(objectIds: [String]) -> [String]
}

final class WorkspaceService: WorkspaceServiceProtocol {
    
    // MARK: - WorkspaceServiceProtocol
    
    func installObjects(objectIds: [String]) -> [String] {
        let result = Anytype_Rpc.Workspace.Object.ListAdd.Service.invocation(objectIds: objectIds)
            .invoke()
            .getValue(domain: .blockListService)
        
        return result?.objectIds ?? []
    }
}
