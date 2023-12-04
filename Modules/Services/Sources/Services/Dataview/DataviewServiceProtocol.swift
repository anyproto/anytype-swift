import ProtobufMessages

public protocol DataviewServiceProtocol {
    func updateView(objectId: BlockId, blockId: BlockId, view: DataviewView) async throws
    
    // MARK: - Filters
    func addFilter(objectId: BlockId, blockId: BlockId, filter: DataviewFilter, viewId: String) async throws
    func removeFilters(objectId: BlockId, blockId: BlockId, ids: [String], viewId: String) async throws
    func replaceFilter(objectId: BlockId, blockId: BlockId, id: String, filter: DataviewFilter, viewId: String) async throws
    
    // MARK: - Sorts
    func addSort(objectId: BlockId, blockId: BlockId, sort: DataviewSort, viewId: String) async throws
    func removeSorts(objectId: BlockId, blockId: BlockId, ids: [String], viewId: String) async throws
    func replaceSort(objectId: BlockId, blockId: BlockId, id: String, sort: DataviewSort, viewId: String) async throws
    func sortSorts(objectId: BlockId, blockId: BlockId, ids: [String], viewId: String) async throws
    
    // MARK: - Relations
    func addViewRelation(objectId: BlockId, blockId: BlockId, relation: MiddlewareRelation, viewId: String) async throws
    func removeViewRelations(objectId: BlockId, blockId: BlockId, keys: [String], viewId: String) async throws
    func replaceViewRelation(objectId: BlockId, blockId: BlockId, key: String, with relation: MiddlewareRelation, viewId: String) async throws
    func sortViewRelations(objectId: BlockId, blockId: BlockId, keys: [String], viewId: String) async throws
    
    @discardableResult
    func createView(objectId: BlockId, blockId: BlockId, view: DataviewView, source: [String]) async throws -> String
    func deleteView(objectId: BlockId, blockId: BlockId, viewId: String) async throws
    func addRelation(objectId: BlockId, blockId: BlockId, relationDetails: RelationDetails) async throws
    func deleteRelation(objectId: BlockId, blockId: BlockId, relationKey: String) async throws
    func addRecord(
        typeUniqueKey: ObjectTypeUniqueKey?,
        templateId: BlockId,
        spaceId: String,
        details: ObjectDetails
    ) async throws -> ObjectDetails
    func setPositionForView(objectId: BlockId, blockId: BlockId, viewId: String, position: Int) async throws
    func objectOrderUpdate(objectId: BlockId, blockId: BlockId, order: [DataviewObjectOrder]) async throws
    func groupOrderUpdate(objectId: BlockId, blockId: BlockId, viewId: String, groupOrder: DataviewGroupOrder) async throws
}
