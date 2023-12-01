import Services
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
    
    func updateView(objectId: BlockId, blockId: BlockId?, view: DataviewView) async throws {
        try await ClientCommands.blockDataviewViewUpdate(.with {
            $0.contextID = objectId
            $0.blockID = blockId ?? Constants.dataview
            $0.viewID = view.id
            $0.view = view.asMiddleware
        }).invoke()
    }
    
    // MARK: - Filters
    
    func addFilter(objectId: BlockId, blockId: BlockId?, filter: DataviewFilter, viewId: String) async throws {
        try await ClientCommands.blockDataviewFilterAdd(.with {
            $0.contextID = objectId
            $0.blockID = blockId ?? Constants.dataview
            $0.viewID = viewId
            $0.filter = filter
        }).invoke()
    }
    
    func removeFilters(objectId: BlockId, blockId: BlockId?, ids: [String], viewId: String) async throws {
        try await ClientCommands.blockDataviewFilterRemove(.with {
            $0.contextID = objectId
            $0.blockID = blockId ?? Constants.dataview
            $0.viewID = viewId
            $0.ids = ids
        }).invoke()
    }
    
    func replaceFilter(objectId: BlockId, blockId: BlockId?, id: String, filter: DataviewFilter, viewId: String) async throws {
        try await ClientCommands.blockDataviewFilterReplace(.with {
            $0.contextID = objectId
            $0.blockID = blockId ?? Constants.dataview
            $0.viewID = viewId
            $0.id = id
            $0.filter = filter
        }).invoke()
    }
    
    // MARK: - Sorts
    
    func addSort(objectId: BlockId, blockId: BlockId?, sort: DataviewSort, viewId: String) async throws {
        try await ClientCommands.blockDataviewSortAdd(.with {
            $0.contextID = objectId
            $0.blockID = blockId ?? Constants.dataview
            $0.viewID = viewId
            $0.sort = sort
        }).invoke()
    }
    
    func removeSorts(objectId: BlockId, blockId: BlockId?, ids: [String], viewId: String) async throws {
        try await ClientCommands.blockDataviewSortRemove(.with {
            $0.contextID = objectId
            $0.blockID = blockId ?? Constants.dataview
            $0.viewID = viewId
            $0.ids = ids
        }).invoke()
    }
    
    func replaceSort(objectId: BlockId, blockId: BlockId?, id: String, sort: DataviewSort, viewId: String) async throws {
        try await ClientCommands.blockDataviewSortReplace(.with {
            $0.contextID = objectId
            $0.blockID = blockId ?? Constants.dataview
            $0.viewID = viewId
            $0.id = id
            $0.sort = sort
        }).invoke()
    }
    
    func sortSorts(objectId: BlockId, blockId: BlockId?, ids: [String], viewId: String) async throws {
        try await ClientCommands.blockDataviewSortSort(.with {
            $0.contextID = objectId
            $0.blockID = blockId ?? Constants.dataview
            $0.viewID = viewId
            $0.ids = ids
        }).invoke()
    }
    
    // MARK: - Relations
    
    func addViewRelation(objectId: BlockId, blockId: BlockId?, relation: MiddlewareRelation, viewId: String) async throws {
        try await ClientCommands.blockDataviewViewRelationAdd(.with {
            $0.contextID = objectId
            $0.blockID = blockId ?? Constants.dataview
            $0.viewID = viewId
            $0.relation = relation
        }).invoke()
    }
    
    func removeViewRelations(objectId: BlockId, blockId: BlockId?, keys: [String], viewId: String) async throws {
        try await ClientCommands.blockDataviewViewRelationRemove(.with {
            $0.contextID = objectId
            $0.blockID = blockId ?? Constants.dataview
            $0.viewID = viewId
            $0.relationKeys = keys
        }).invoke()
    }
    
    func replaceViewRelation(objectId: BlockId, blockId: BlockId?, key: String, with relation: MiddlewareRelation, viewId: String) async throws {
        try await ClientCommands.blockDataviewViewRelationReplace(.with {
            $0.contextID = objectId
            $0.blockID = blockId ?? Constants.dataview
            $0.viewID = viewId
            $0.relationKey = key
            $0.relation = relation
        }).invoke()
    }
    
    func sortViewRelations(objectId: BlockId, blockId: BlockId?, keys: [String], viewId: String) async throws {
        try await ClientCommands.blockDataviewViewRelationSort(.with {
            $0.contextID = objectId
            $0.blockID = blockId ?? Constants.dataview
            $0.viewID = viewId
            $0.relationKeys = keys
        }).invoke()
    }
    
    // MARK: -

    func createView(objectId: BlockId, blockId: BlockId?, view: DataviewView, source: [String]) async throws -> String {
        let response = try await ClientCommands.blockDataviewViewCreate(.with {
            $0.contextID = objectId
            $0.blockID = blockId ?? Constants.dataview
            $0.view = view.asMiddleware
            $0.source = source
        }).invoke()
        return response.viewID
    }

    func deleteView(objectId: BlockId, blockId: BlockId?, viewId: String) async throws {
        try await ClientCommands.blockDataviewViewDelete(.with {
            $0.contextID = objectId
            $0.blockID = blockId ?? Constants.dataview
            $0.viewID = viewId
        }).invoke()
    }

    func addRelation(objectId: BlockId, blockId: BlockId?, relationDetails: RelationDetails) async throws {
        try await ClientCommands.blockDataviewRelationAdd(.with {
            $0.contextID = objectId
            $0.blockID = blockId ?? Constants.dataview
            $0.relationKeys = [relationDetails.key]
        }).invoke()
    }
    
    func deleteRelation(objectId: BlockId, blockId: BlockId?, relationKey: String) async throws {
        try await ClientCommands.blockDataviewRelationDelete(.with {
            $0.contextID = objectId
            $0.blockID = blockId ?? Constants.dataview
            $0.relationKeys = [relationKey]
        }).invoke()
    }
    
    func addRecord(
        typeUniqueKey: ObjectTypeUniqueKey?,
        templateId: BlockId,
        spaceId: String,
        setFilters: [SetFilter],
        relationsDetails: [RelationDetails]
    ) async throws -> ObjectDetails {
        let prefilledFields = prefilledFieldsBuilder.buildPrefilledFields(from: setFilters, relationsDetails: relationsDetails)
        
        let internalFlags: [Anytype_Model_InternalFlag] = .builder {
            Anytype_Model_InternalFlag.with { $0.value = .editorSelectTemplate }
        }

        let details: Google_Protobuf_Struct = .init(fields: prefilledFields)

        let response = try await ClientCommands.objectCreate(.with {
            $0.details = details
            $0.internalFlags = internalFlags
            $0.templateID = templateId
            $0.spaceID = spaceId
            if let typeUniqueKey {
                $0.objectTypeUniqueKey = typeUniqueKey.value
            }
        }).invoke()

        return try ObjectDetails(protobufStruct: response.details)
    }
    
    func setPositionForView(objectId: BlockId, viewId: String, position: Int) async throws {
        try await ClientCommands.blockDataviewViewSetPosition(.with {
            $0.contextID = objectId
            $0.blockID = Constants.dataview
            $0.viewID = viewId
            $0.position = UInt32(position)
        }).invoke()
    }
    
    func objectOrderUpdate(objectId: BlockId, viewId: String, groupObjectIds: [GroupObjectIds]) async throws {
        let objectOrders: [Anytype_Model_Block.Content.Dataview.ObjectOrder] = groupObjectIds.map { groupObjectId in
            Anytype_Model_Block.Content.Dataview.ObjectOrder.with {
                $0.viewID = viewId
                $0.groupID = groupObjectId.groupId
                $0.objectIds = groupObjectId.objectIds
            }
        }
        try await ClientCommands.blockDataviewObjectOrderUpdate(.with {
            $0.contextID = objectId
            $0.blockID = Constants.dataview
            $0.objectOrders = objectOrders
        }).invoke()
    }
    
    func groupOrderUpdate(objectId: BlockId, viewId: String, groupOrder: DataviewGroupOrder) async throws {
        try await ClientCommands.blockDataviewGroupOrderUpdate(.with {
            $0.contextID = objectId
            $0.blockID = Constants.dataview
            $0.groupOrder = groupOrder
        }).invoke()
    }
}
