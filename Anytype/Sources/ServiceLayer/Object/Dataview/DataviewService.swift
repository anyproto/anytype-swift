import BlocksModels
import ProtobufMessages
import SwiftProtobuf
import Combine
import AnytypeCore

final class DataviewService: DataviewServiceProtocol {
    private let objectId: BlockId
    private let prefilledFieldsBuilder: SetFilterPrefilledFieldsBuilderProtocol
    
    init(objectId: BlockId, prefilledFieldsBuilder: SetFilterPrefilledFieldsBuilderProtocol) {
        self.objectId = objectId
        self.prefilledFieldsBuilder = prefilledFieldsBuilder
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
        #warning("Fix me")
        return false
//        let events = Anytype_Rpc.BlockDataview.Relation.Add.Service
//            .invoke(contextID: objectId, blockID: SetConstants.dataviewBlockId, relation: relation.asMiddleware)
//            .map { EventsBunch(event: $0.event) }
//            .getValue(domain: .dataviewService)
//
//        events?.send()
//
//        return events.isNotNil
    }
    
    func deleteRelation(key: BlockId) {
        #warning("Fix me")
//        Anytype_Rpc.BlockDataview.Relation.Delete.Service
//            .invoke(contextID: objectId, blockID: SetConstants.dataviewBlockId, relationKey: key)
//            .map { EventsBunch(event: $0.event) }
//            .getValue(domain: .dataviewService)?
//            .send()
    }
    
    func addRecord(templateId: BlockId, setFilters: [SetFilter]) -> ObjectDetails? {
        var prefilledFields = prefilledFieldsBuilder.buildPrefilledFields(from: setFilters)
        
        let internalFlags: [Int] = [
            Anytype_Model_InternalFlag(value: .editorSelectTemplate).value.rawValue,
            Anytype_Model_InternalFlag(value: .editorSelectType).value.rawValue
        ]
        prefilledFields[BundledRelationKey.internalFlags.rawValue] = internalFlags.protobufValue
       
        let protobufStruct: Google_Protobuf_Struct = .init(fields: prefilledFields)

        #warning("Fix me")
        return nil
//        let response = Anytype_Rpc.BlockDataviewRecord.Create.Service
//            .invoke(
//                contextID: objectId,
//                blockID: SetConstants.dataviewBlockId,
//                record: protobufStruct,
//                templateID: templateId
//            )
//            .getValue(domain: .dataviewService)
//
//        guard let response = response else { return nil }
//
//        let idValue = response.record.fields[BundledRelationKey.id.rawValue]
//        let idString = idValue?.unwrapedListValue.stringValue
//
//        guard let id = idString else { return nil }
//
//        return ObjectDetails(id: id, values: response.record.fields)
    }
}
