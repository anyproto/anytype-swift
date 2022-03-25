import BlocksModels
import ProtobufMessages

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
            .getValue(domain: .anytypeColor)?
            .send()
    }
}
