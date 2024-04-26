import ProtobufMessages
import SwiftProtobuf
import Combine
import AnytypeCore

public final class DataviewService: DataviewServiceProtocol {
  
    public init() {}
    
    public func updateView(objectId: BlockId, blockId: BlockId, view: DataviewView) async throws {
        try await ClientCommands.blockDataviewViewUpdate(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = view.id
            $0.view = view.asMiddleware
        }).invoke()
    }
    
    // MARK: - Filters
    
    public func addFilter(objectId: BlockId, blockId: BlockId, filter: DataviewFilter, viewId: String) async throws {
        try await ClientCommands.blockDataviewFilterAdd(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.filter = filter
        }).invoke()
    }
    
    public func removeFilters(objectId: BlockId, blockId: BlockId, ids: [String], viewId: String) async throws {
        try await ClientCommands.blockDataviewFilterRemove(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.ids = ids
        }).invoke()
    }
    
    public func replaceFilter(objectId: BlockId, blockId: BlockId, id: String, filter: DataviewFilter, viewId: String) async throws {
        try await ClientCommands.blockDataviewFilterReplace(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.id = id
            $0.filter = filter
        }).invoke()
    }
    
    // MARK: - Sorts
    
    public func addSort(objectId: BlockId, blockId: BlockId, sort: DataviewSort, viewId: String) async throws {
        try await ClientCommands.blockDataviewSortAdd(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.sort = sort
        }).invoke()
    }
    
    public func removeSorts(objectId: BlockId, blockId: BlockId, ids: [String], viewId: String) async throws {
        try await ClientCommands.blockDataviewSortRemove(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.ids = ids
        }).invoke()
    }
    
    public func replaceSort(objectId: BlockId, blockId: BlockId, id: String, sort: DataviewSort, viewId: String) async throws {
        try await ClientCommands.blockDataviewSortReplace(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.id = id
            $0.sort = sort
        }).invoke()
    }
    
    public func sortSorts(objectId: BlockId, blockId: BlockId, ids: [String], viewId: String) async throws {
        try await ClientCommands.blockDataviewSortSort(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.ids = ids
        }).invoke()
    }
    
    // MARK: - Relations
    
    public func addViewRelation(objectId: BlockId, blockId: BlockId, relation: MiddlewareRelation, viewId: String) async throws {
        try await ClientCommands.blockDataviewViewRelationAdd(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.relation = relation
        }).invoke()
    }
    
    public func removeViewRelations(objectId: BlockId, blockId: BlockId, keys: [String], viewId: String) async throws {
        try await ClientCommands.blockDataviewViewRelationRemove(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.relationKeys = keys
        }).invoke()
    }
    
    public func replaceViewRelation(objectId: BlockId, blockId: BlockId, key: String, with relation: MiddlewareRelation, viewId: String) async throws {
        try await ClientCommands.blockDataviewViewRelationReplace(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.relationKey = key
            $0.relation = relation
        }).invoke()
    }
    
    public func sortViewRelations(objectId: BlockId, blockId: BlockId, keys: [String], viewId: String) async throws {
        try await ClientCommands.blockDataviewViewRelationSort(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.relationKeys = keys
        }).invoke()
    }
    
    // MARK: -

    public func createView(objectId: BlockId, blockId: BlockId, view: DataviewView, source: [String]) async throws -> String {
        let response = try await ClientCommands.blockDataviewViewCreate(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.view = view.asMiddleware
            $0.source = source
        }).invoke()
        return response.viewID
    }

    public func deleteView(objectId: BlockId, blockId: BlockId, viewId: String) async throws {
        try await ClientCommands.blockDataviewViewDelete(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
        }).invoke()
    }

    public func addRelation(objectId: BlockId, blockId: BlockId, relationDetails: RelationDetails) async throws {
        try await ClientCommands.blockDataviewRelationAdd(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.relationKeys = [relationDetails.key]
        }).invoke()
    }
    
    public func deleteRelation(objectId: BlockId, blockId: BlockId, relationKey: String) async throws {
        try await ClientCommands.blockDataviewRelationDelete(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.relationKeys = [relationKey]
        }).invoke()
    }
    
    public func addRecord(
        typeUniqueKey: ObjectTypeUniqueKey?,
        templateId: BlockId,
        spaceId: String,
        details: ObjectDetails
    ) async throws -> ObjectDetails {
        
        let internalFlags: [Anytype_Model_InternalFlag] = .builder {
            Anytype_Model_InternalFlag.with { $0.value = .editorSelectTemplate }
        }

        let details: Google_Protobuf_Struct = .init(fields: details.values)

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
    
    public func setPositionForView(objectId: BlockId, blockId: BlockId, viewId: String, position: Int) async throws {
        try await ClientCommands.blockDataviewViewSetPosition(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.viewID = viewId
            $0.position = UInt32(position)
        }).invoke()
    }
    
    public func objectOrderUpdate(objectId: BlockId, blockId: BlockId, order: [DataviewObjectOrder]) async throws {
        try await ClientCommands.blockDataviewObjectOrderUpdate(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.objectOrders = order
        }).invoke()
    }
    
    public func groupOrderUpdate(objectId: BlockId, blockId: BlockId, viewId: String, groupOrder: DataviewGroupOrder) async throws {
        try await ClientCommands.blockDataviewGroupOrderUpdate(.with {
            $0.contextID = objectId
            $0.blockID = blockId
            $0.groupOrder = groupOrder
        }).invoke()
    }
}
