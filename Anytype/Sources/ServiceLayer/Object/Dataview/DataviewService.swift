import BlocksModels
import ProtobufMessages
import SwiftProtobuf
import Combine
import AnytypeCore

final class DataviewService: DataviewServiceProtocol {
    private let objectId: BlockId
    
    init(objectId: BlockId) {
        self.objectId = objectId
    }
    
    func updateView( _ view: DataviewView) {
        Anytype_Rpc.BlockDataview.View.Update.Service
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
        let events = Anytype_Rpc.BlockDataview.Relation.Add.Service
            .invoke(contextID: objectId, blockID: SetConstants.dataviewBlockId, relation: relation.asMiddleware)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .dataviewService)
        
        events?.send()
        
        return events.isNotNil
    }
    
    func deleteRelation(key: BlockId) {
        Anytype_Rpc.BlockDataview.Relation.Delete.Service
            .invoke(contextID: objectId, blockID: SetConstants.dataviewBlockId, relationKey: key)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .dataviewService)?
            .send()
    }

    func addRecord() -> ObjectDetails? {
        var protoFields = [String: Google_Protobuf_Value]()
        protoFields[BundledRelationKey.isDraft.rawValue] = true

        let protobufStruct: Google_Protobuf_Struct = .init(fields: protoFields)

        let response = Anytype_Rpc.BlockDataviewRecord.Create.Service
            .invoke(
                contextID: objectId,
                blockID: SetConstants.dataviewBlockId,
                record: protobufStruct,
                templateID: .empty
            )
            .getValue(domain: .dataviewService)

        guard let response = response else { return nil }

        let idValue = response.record.fields[BundledRelationKey.id.rawValue]
        let idString = idValue?.unwrapedListValue.stringValue

        guard let id = idString else { return nil }

        return ObjectDetails(id: id, values: response.record.fields)
    }
}
