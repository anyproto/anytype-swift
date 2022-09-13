import BlocksModels
import ProtobufMessages
import SwiftProtobuf
import Combine
import AnytypeCore

final class DataviewService: DataviewServiceProtocol {
    enum Constants {
        static let dataview = "dataview"
    }

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

    func createView( _ view: DataviewView) {
        Anytype_Rpc.BlockDataview.View.Create.Service
            .invoke(contextID: objectId, blockID: SetConstants.dataviewBlockId, view: view.asMiddleware)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .dataviewService)?
            .send()
    }

    func deleteView( _ viewId: String) {
        Anytype_Rpc.BlockDataview.View.Delete.Service
            .invoke(contextID: objectId, blockID: SetConstants.dataviewBlockId, viewID: viewId)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .dataviewService)?
            .send()
    }

    func addRelation(_ relation: Relation) -> Bool {
        let events = Anytype_Rpc.BlockDataview.Relation.Add.Service
            .invoke(contextID: objectId, blockID: SetConstants.dataviewBlockId, relationIds: [relation.id])
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .dataviewService)
        
        events?.send()
        
        return events.isNotNil
    }
    
    func deleteRelation(relationId: BlockId) {
        #warning("Check me")
        Anytype_Rpc.BlockDataview.Relation.Delete.Service
            .invoke(contextID: objectId, blockID: SetConstants.dataviewBlockId, relationIds: [relationId])
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

    func setSource(typeObjectId: String) {
        Anytype_Rpc.BlockDataview.SetSource.Service.invoke(
            contextID: objectId,
            blockID: Constants.dataview,
            source: [typeObjectId]
        )
        .map { EventsBunch(event: $0.event) }
        .getValue(domain: .dataviewService)?
        .send()
    }

    func setPositionForView(_ viewId: String, position: Int) {
        Anytype_Rpc.BlockDataview.View.SetPosition.Service
            .invoke(
                contextID: objectId,
                blockID: Constants.dataview,
                viewID: viewId,
                position: UInt32(position)
            )
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .dataviewService)?
            .send()
    }
}
