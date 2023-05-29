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
        try await ClientCommands.blockDataviewViewUpdate(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = view.id
            $0.view = view.asMiddleware
        }).invoke(errorDomain: .dataviewService)
    }
    
    // MARK: - Filters
    
    func addFilter(_ filter: DataviewFilter, viewId: String) async throws {
        try await ClientCommands.blockDataviewFilterAdd(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.filter = filter
        }).invoke(errorDomain: .dataviewService)
    }
    
    func removeFilters(_ ids: [String], viewId: String) async throws {
        try await ClientCommands.blockDataviewFilterRemove(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.ids = ids
        }).invoke(errorDomain: .dataviewService)
    }
    
    func replaceFilter(_ id: String, with filter: DataviewFilter, viewId: String) async throws {
        try await ClientCommands.blockDataviewFilterReplace(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.id = id
            $0.filter = filter
        }).invoke(errorDomain: .dataviewService)
    }
    
    // MARK: - Sorts
    
    func addSort(_ sort: DataviewSort, viewId: String) async throws {
        try await ClientCommands.blockDataviewSortAdd(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.sort = sort
        }).invoke(errorDomain: .dataviewService)
    }
    
    func removeSorts(_ ids: [String], viewId: String) async throws {
        try await ClientCommands.blockDataviewSortRemove(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.ids = ids
        }).invoke(errorDomain: .dataviewService)
    }
    
    func replaceSort(_ id: String, with sort: DataviewSort, viewId: String) async throws {
        try await ClientCommands.blockDataviewSortReplace(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.id = id
            $0.sort = sort
        }).invoke(errorDomain: .dataviewService)
    }
    
    func sortSorts(_ ids: [String], viewId: String) async throws {
        try await ClientCommands.blockDataviewSortSort(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.ids = ids
        }).invoke(errorDomain: .dataviewService)
    }
    
    // MARK: - Relations
    
    func addViewRelation(_ relation: MiddlewareRelation, viewId: String) async throws {
        try await ClientCommands.blockDataviewViewRelationAdd(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.relation = relation
        }).invoke(errorDomain: .dataviewService)
    }
    
    func removeViewRelations(_ keys: [String], viewId: String) async throws {
        try await ClientCommands.blockDataviewViewRelationRemove(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.relationKeys = keys
        }).invoke(errorDomain: .dataviewService)
    }
    
    func replaceViewRelation(_ key: String, with relation: MiddlewareRelation, viewId: String) async throws {
        try await ClientCommands.blockDataviewViewRelationReplace(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.relationKey = key
            $0.relation = relation
        }).invoke(errorDomain: .dataviewService)
    }
    
    func sortViewRelations(_ keys: [String], viewId: String) async throws {
        try await ClientCommands.blockDataviewViewRelationSort(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.relationKeys = keys
        }).invoke(errorDomain: .dataviewService)
    }
    
    // MARK: -

    func createView( _ view: DataviewView, source: [String]) async throws {
        try await ClientCommands.blockDataviewViewCreate(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.view = view.asMiddleware
            $0.source = source
        }).invoke(errorDomain: .dataviewService)
    }

    func deleteView( _ viewId: String) async throws {
        try await ClientCommands.blockDataviewViewDelete(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
        }).invoke(errorDomain: .dataviewService)
    }

    func addRelation(_ relationDetails: RelationDetails) async throws {
        try await ClientCommands.blockDataviewRelationAdd(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.relationKeys = [relationDetails.key]
        }).invoke(errorDomain: .dataviewService)
    }
    
    func deleteRelation(relationKey: String) async throws {
        try await ClientCommands.blockDataviewRelationDelete(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.relationKeys = [relationKey]
        }).invoke(errorDomain: .dataviewService)
    }
    
    func addRecord(
        objectType: String,
        shouldSelectType: Bool,
        templateId: BlockId,
        setFilters: [SetFilter],
        relationsDetails: [RelationDetails]
    ) async throws -> String {
        var prefilledFields = prefilledFieldsBuilder.buildPrefilledFields(from: setFilters, relationsDetails: relationsDetails)
        prefilledFields[BundledRelationKey.type.rawValue] = objectType.protobufValue

        let internalFlags: [Anytype_Model_InternalFlag] = .builder {
            Anytype_Model_InternalFlag.with { $0.value = .editorSelectTemplate }
            if shouldSelectType {
                Anytype_Model_InternalFlag.with { $0.value = .editorSelectType }
            }
        }

        let details: Google_Protobuf_Struct = .init(fields: prefilledFields)

        let response = try await ClientCommands.objectCreate(.with {
            $0.details = details
            $0.internalFlags = internalFlags
            $0.templateID = templateId
        }).invoke(errorDomain: .dataviewService)

        return response.objectID
    }
    
    func setPositionForView(_ viewId: String, position: Int) async throws {
        try await ClientCommands.blockDataviewViewSetPosition(.with {
            $0.contextID = objectId
            $0.blockID = Constants.dataview
            $0.viewID = viewId
            $0.position = UInt32(position)
        }).invoke(errorDomain: .dataviewService)
    }
    
    func objectOrderUpdate(viewId: String, groupObjectIds: [GroupObjectIds]) async throws {
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
        }).invoke(errorDomain: .dataviewService)
    }
    
    func groupOrderUpdate(viewId: String, groupOrder: DataviewGroupOrder) async throws {
        try await ClientCommands.blockDataviewGroupOrderUpdate(.with {
            $0.contextID = objectId
            $0.blockID = Constants.dataview
            $0.groupOrder = groupOrder
        }).invoke(errorDomain: .dataviewService)
    }
}
