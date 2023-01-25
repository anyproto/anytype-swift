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
    private let blockId: BlockId
    private let prefilledFieldsBuilder: SetPrefilledFieldsBuilderProtocol
    
    init(objectId: BlockId, blockId: BlockId?, prefilledFieldsBuilder: SetPrefilledFieldsBuilderProtocol) {
        self.objectId = objectId
        self.blockId = blockId ?? SetConstants.dataviewBlockId
        self.prefilledFieldsBuilder = prefilledFieldsBuilder
    }
    
    func updateView(_ view: DataviewView) async throws {
        let result = try await Anytype_Rpc.BlockDataview.View.Update.Service
            .invocation(
                contextID: objectId,
                blockID: blockId,
                viewID: view.id,
                view: view.asMiddleware
            )
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
    
    // MARK: - Filters
    
    func addFilter(_ filter: DataviewFilter, viewId: String) async throws {
        let result = try await Anytype_Rpc.BlockDataview.Filter.Add.Service
            .invocation(
                contextID: objectId,
                blockID: blockId,
                viewID: viewId,
                filter: filter
            )
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
    
    func removeFilters(_ filterIds: [String], viewId: String) async throws {
        let result = try await Anytype_Rpc.BlockDataview.Filter.Remove.Service
            .invocation(
                contextID: objectId,
                blockID: blockId,
                viewID: viewId,
                filterIds: filterIds
            )
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
    
    func replaceFilter(_ filterId: String, with filter: DataviewFilter, viewId: String) async throws {
        let result = try await Anytype_Rpc.BlockDataview.Filter.Replace.Service
            .invocation(
                contextID: objectId,
                blockID: blockId,
                viewID: viewId,
                filterID: filterId,
                filter: filter
            )
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
    
    // MARK: - Sorts
    
    func addSort(_ sort: DataviewSort, viewId: String) async throws {
        let result = try await Anytype_Rpc.BlockDataview.Sort.Add.Service
            .invocation(
                contextID: objectId,
                blockID: blockId,
                viewID: viewId,
                sort: sort
            )
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
    
    func removeSorts(_ sortIds: [String], viewId: String) async throws {
        let result = try await Anytype_Rpc.BlockDataview.Sort.Remove.Service
            .invocation(
                contextID: objectId,
                blockID: blockId,
                viewID: viewId,
                ids: sortIds
            )
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
    
    func replaceSort(_ sortId: String, with sort: DataviewSort, viewId: String) async throws {
        let result = try await Anytype_Rpc.BlockDataview.Sort.Replace.Service
            .invocation(
                contextID: objectId,
                blockID: blockId,
                viewID: viewId,
                id: sortId,
                sort: sort
            )
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
    
    func sortSorts(_ sortIds: [String], viewId: String) async throws {
        let result = try await Anytype_Rpc.BlockDataview.Sort.Sort.Service
            .invocation(
                contextID: objectId,
                blockID: blockId,
                viewID: viewId,
                ids: sortIds
            )
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
    
    // MARK: - Relations
    
    func addViewRelation(_ relation: MiddlewareRelation, viewId: String) async throws {
        let result = try await Anytype_Rpc.BlockDataview.ViewRelation.Add.Service
            .invocation(
                contextID: objectId,
                blockID: blockId,
                viewID: viewId,
                relation: relation
            )
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
    
    func removeViewRelations(_ keys: [String], viewId: String) async throws {
        let result = try await Anytype_Rpc.BlockDataview.ViewRelation.Remove.Service
            .invocation(
                contextID: objectId,
                blockID: blockId,
                viewID: viewId,
                relationKeys: keys
            )
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
    
    func replaceViewRelation(_ key: String, with relation: MiddlewareRelation, viewId: String) async throws {
        let result = try await Anytype_Rpc.BlockDataview.ViewRelation.Replace.Service
            .invocation(
                contextID: objectId,
                blockID: blockId,
                viewID: viewId,
                relationKey: key,
                relation: relation
            )
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
    
    func sortViewRelations(_ keys: [String], viewId: String) async throws {
        let result = try await Anytype_Rpc.BlockDataview.ViewRelation.Sort.Service
            .invocation(
                contextID: objectId,
                blockID: blockId,
                viewID: viewId,
                relationKeys: keys
            )
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
    
    // MARK: -

    func createView( _ view: DataviewView, source: [String]) async throws {
        let result = try await Anytype_Rpc.BlockDataview.View.Create.Service
            .invocation(
                contextID: objectId,
                blockID: blockId,
                view: view.asMiddleware,
                source: source
            )
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }

    func deleteView( _ viewId: String) async throws {
        let result = try await Anytype_Rpc.BlockDataview.View.Delete.Service
            .invocation(contextID: objectId, blockID: blockId, viewID: viewId)
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }

    func addRelation(_ relationDetails: RelationDetails) async throws -> Bool {
        let result = try await Anytype_Rpc.BlockDataview.Relation.Add.Service
            .invocation(contextID: objectId, blockID: blockId, relationKeys: [relationDetails.key])
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
        
        return result.hasEvent
    }
    
    func deleteRelation(relationKey: String) async throws {
        let result = try await Anytype_Rpc.BlockDataview.Relation.Delete.Service
            .invocation(contextID: objectId, blockID: blockId, relationKeys: [relationKey])
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
    
    func addRecord(
        objectType: String,
        templateId: BlockId,
        setFilters: [SetFilter],
        relationsDetails: [RelationDetails]
    ) async throws -> String {
        var prefilledFields = prefilledFieldsBuilder.buildPrefilledFields(from: setFilters, relationsDetails: relationsDetails)
        prefilledFields[BundledRelationKey.type.rawValue] = objectType.protobufValue

        let internalFlags: [Anytype_Model_InternalFlag] = [
            Anytype_Model_InternalFlag(value: .editorSelectTemplate)
        ]

        let details: Google_Protobuf_Struct = .init(fields: prefilledFields)

        let response = try await Anytype_Rpc.Object.Create.Service
            .invocation(details: details, internalFlags: internalFlags, templateID: templateId)
            .invoke(errorDomain: .dataviewService)

        EventsBunch(event: response.event).send()

        return response.objectID
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
    
    func groupOrderUpdate(viewId: String, groupOrder: DataviewGroupOrder) async throws {
        let result = try await Anytype_Rpc.BlockDataview.GroupOrder.Update.Service
            .invocation(
                contextID: objectId,
                blockID: Constants.dataview,
                groupOrder: groupOrder
            )
            .invoke(errorDomain: .dataviewService)
        let event = EventsBunch(event: result.event)
        event.send()
    }
}
