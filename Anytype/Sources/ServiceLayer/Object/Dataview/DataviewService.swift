import BlocksModels
import ProtobufMessages
import Combine
import AnytypeCore

final class DataviewService: DataviewServiceProtocol {
    private let objectId: BlockId
    
    init(objectId: BlockId) {
        self.objectId = objectId
    }
    
    func updateView( _ view: DataviewView) {
        Anytype_Rpc.Block.Dataview.ViewUpdate.Service
            .invoke(
                contextID: objectId,
                blockID: SetConstants.dataviewBlockId,
                viewID: view.id,
                view: view.asMiddleware
            )
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .dataviewService)?
            .send()
    }
    
    func addRelation(_ relation: RelationMetadata) -> Bool {
        let events = Anytype_Rpc.Block.Dataview.RelationAdd.Service
            .invoke(contextID: objectId, blockID: SetConstants.dataviewBlockId, relation: relation.asMiddleware)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .dataviewService)
        
        events?.send()
        
        return events.isNotNil
    }
}
