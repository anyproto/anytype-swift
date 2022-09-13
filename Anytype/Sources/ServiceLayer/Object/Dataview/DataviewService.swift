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
    
    func addRelation(_ relation: Relation) -> Bool {
        let events = Anytype_Rpc.BlockDataview.Relation.Add.Service
            .invoke(contextID: objectId, blockID: SetConstants.dataviewBlockId, relationID: relation.id)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .dataviewService)
        
        events?.send()
        
        return events.isNotNil
    }
    
    func deleteRelation(relationId: BlockId) {
        #warning("Check me")
//        Anytype_Rpc.ObjectRelation.Delete.Service
//            .invocation(contextID: objectId, relationID: relationId)
//            .invoke()
//            .map { EventsBunch(event: $0.event) }
//            .getValue(domain: .relationsService)?
//            .send()
        Anytype_Rpc.BlockDataview.Relation.Delete.Service
            .invoke(contextID: objectId, blockID: SetConstants.dataviewBlockId, relationID: relationId)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .dataviewService)?
            .send()
    }
    
    func addRecord(objectType: String, templateId: BlockId, setFilters: [SetFilter]) -> String? {
        var prefilledFields = prefilledFieldsBuilder.buildPrefilledFields(from: setFilters)
        prefilledFields[BundledRelationKey.type.rawValue] = objectType.protobufValue
        
        let internalFlags: [Anytype_Model_InternalFlag] = [
            Anytype_Model_InternalFlag(value: .editorSelectTemplate),
            Anytype_Model_InternalFlag(value: .editorSelectType)
        ]
        
        let details: Google_Protobuf_Struct = .init(fields: prefilledFields)
        
        let response = Anytype_Rpc.Object.Create.Service
            .invocation(details: details, internalFlags: internalFlags, templateID: templateId)
            .invoke()
            .getValue(domain: .dataviewService)
        
        guard let response = response else { return nil }
                
        EventsBunch(event: response.event).send()
        
        return response.objectID
    }
}
