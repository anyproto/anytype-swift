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

    func addRelation(_ relationDetails: RelationDetails) async throws -> Bool {
        let result = try await Anytype_Rpc.BlockDataview.Relation.Add.Service
            .invocation(contextID: objectId, blockID: SetConstants.dataviewBlockId, relationKeys: [relationDetails.key])
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
        
        return result.hasEvent
    }
    
    func deleteRelation(relationKey: String) async throws {
        let result = try await Anytype_Rpc.BlockDataview.Relation.Delete.Service
            .invocation(contextID: objectId, blockID: SetConstants.dataviewBlockId, relationKeys: [relationKey])
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
    
    func addRecord(objectType: String, templateId: BlockId, setFilters: [SetFilter]) async throws -> String {
        var prefilledFields = prefilledFieldsBuilder.buildPrefilledFields(from: setFilters)
        prefilledFields[BundledRelationKey.type.rawValue] = objectType.protobufValue

        let internalFlags: [Anytype_Model_InternalFlag] = [
            Anytype_Model_InternalFlag(value: .editorSelectTemplate),
            Anytype_Model_InternalFlag(value: .editorSelectType)
        ]

        let details: Google_Protobuf_Struct = .init(fields: prefilledFields)

        let response = try await Anytype_Rpc.Object.Create.Service
            .invocation(details: details, internalFlags: internalFlags, templateID: templateId)
            .invoke(errorDomain: .dataviewService)

        EventsBunch(event: response.event).send()

        return response.objectID
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
    
    func objectOrderUpdate(viewId: String, groupObjectIds: [GroupObjectIds]) async throws {
        let objectOrders: [Anytype_Model_Block.Content.Dataview.ObjectOrder] = groupObjectIds.map {
            Anytype_Model_Block.Content.Dataview.ObjectOrder(
                viewID: viewId,
                groupID: $0.groupId,
                objectIds: $0.objectIds
            )
        }
        let result = try await Anytype_Rpc.BlockDataview.ObjectOrder.Update.Service
            .invocation(
                contextID: objectId,
                blockID: Constants.dataview,
                objectOrders: objectOrders
            )
            .invoke(errorDomain: .dataviewService)

        let event = EventsBunch(event: result.event)
        event.send()
    }
}
