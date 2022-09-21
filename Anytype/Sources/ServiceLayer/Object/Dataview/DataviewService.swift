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
    
    func updateView( _ view: DataviewView) async throws {
        let result = try await Anytype_Rpc.BlockDataview.View.Update.Service
            .invocation(
                contextID: objectId,
                blockID: SetConstants.dataviewBlockId,
                viewID: view.id,
                view: view.asMiddleware
            )
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
    
    func createView( _ view: DataviewView) async throws {
        let result = try await Anytype_Rpc.BlockDataview.View.Create.Service
            .invocation(contextID: objectId, blockID: SetConstants.dataviewBlockId, view: view.asMiddleware)
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
    
    func deleteView( _ viewId: String) async throws {
        let result = try await Anytype_Rpc.BlockDataview.View.Delete.Service
            .invocation(contextID: objectId, blockID: SetConstants.dataviewBlockId, viewID: viewId)
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
    
    func addRelation(_ relation: RelationMetadata) -> Bool {
        let events = Anytype_Rpc.BlockDataview.Relation.Add.Service
            .invoke(contextID: objectId, blockID: SetConstants.dataviewBlockId, relation: relation.asMiddleware)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .dataviewService)
        
        events?.send()
        
        return events.isNotNil
    }
    
    func deleteRelation(key: BlockId) async throws {
        let result = try await Anytype_Rpc.BlockDataview.Relation.Delete.Service
            .invocation(contextID: objectId, blockID: SetConstants.dataviewBlockId, relationKey: key)
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
    
    func addRecord(templateId: BlockId, setFilters: [SetFilter]) async throws -> ObjectDetails? {
        var prefilledFields = prefilledFieldsBuilder.buildPrefilledFields(from: setFilters)
        
        let internalFlags: [Int] = [
            Anytype_Model_InternalFlag(value: .editorSelectTemplate).value.rawValue,
            Anytype_Model_InternalFlag(value: .editorSelectType).value.rawValue
        ]
        prefilledFields[BundledRelationKey.internalFlags.rawValue] = internalFlags.protobufValue
       
        let protobufStruct: Google_Protobuf_Struct = .init(fields: prefilledFields)

        let response = try await Anytype_Rpc.BlockDataviewRecord.Create.Service
            .invocation(
                contextID: objectId,
                blockID: SetConstants.dataviewBlockId,
                record: protobufStruct,
                templateID: templateId
            )
            .invoke(errorDomain: .dataviewService)

        let idValue = response.record.fields[BundledRelationKey.id.rawValue]
        let idString = idValue?.unwrapedListValue.stringValue

        guard let id = idString else { return nil }

        return ObjectDetails(id: id, values: response.record.fields)
    }

    func setSource(typeObjectId: String) async throws {
        let result = try await Anytype_Rpc.BlockDataview.SetSource.Service
            .invocation(
                contextID: objectId,
                blockID: Constants.dataview,
                source: [typeObjectId]
            )
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
    
    func setPositionForView(_ viewId: String, position: Int) async throws {
        let result = try await Anytype_Rpc.BlockDataview.View.SetPosition.Service
            .invocation(
                contextID: objectId,
                blockID: Constants.dataview,
                viewID: viewId,
                position: UInt32(position)
            )
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
}
