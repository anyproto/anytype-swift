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
    
    func deleteRelation(key: BlockId) {
        Anytype_Rpc.Block.Dataview.RelationDelete.Service
            .invoke(contextID: objectId, blockID: SetConstants.dataviewBlockId, relationKey: key)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .dataviewService)?
            .send()
    }

    func addRecord() -> ObjectDetails? {
        let response = Anytype_Rpc.Block.Dataview.RecordCreate.Service
            .invoke(contextID: objectId, blockID: SetConstants.dataviewBlockId, record: .init(), templateID: .empty)
            .getValue(domain: .dataviewService)

        guard let response = response else { return nil }

        let idValue = response.record.fields[BundledRelationKey.id.rawValue]
        let idString = idValue?.unwrapedListValue.stringValue

        guard let id = idString?.asAnytypeId else { return nil }

        return ObjectDetails(id: id, values: response.record.fields)
    }
}
