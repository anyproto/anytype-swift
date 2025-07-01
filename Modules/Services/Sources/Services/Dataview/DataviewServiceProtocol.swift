import ProtobufMessages

public protocol DataviewServiceProtocol: Sendable {
    func updateView(objectId: String, blockId: String, view: DataviewView) async throws
    func setActiveView(objectId: String, blockId: String, viewId: String) async throws
    
    // MARK: - Filters
    func addFilter(objectId: String, blockId: String, filter: DataviewFilter, viewId: String) async throws
    func removeFilters(objectId: String, blockId: String, ids: [String], viewId: String) async throws
    func replaceFilter(objectId: String, blockId: String, id: String, filter: DataviewFilter, viewId: String) async throws
    
    // MARK: - Sorts
    func addSort(objectId: String, blockId: String, sort: DataviewSort, viewId: String) async throws
    func removeSorts(objectId: String, blockId: String, ids: [String], viewId: String) async throws
    func replaceSort(objectId: String, blockId: String, id: String, sort: DataviewSort, viewId: String) async throws
    func sortSorts(objectId: String, blockId: String, ids: [String], viewId: String) async throws
    
    // MARK: - Relations
    func addViewRelation(objectId: String, blockId: String, relation: MiddlewareRelation, viewId: String) async throws
    func removeViewRelations(objectId: String, blockId: String, keys: [String], viewId: String) async throws
    func replaceViewRelation(objectId: String, blockId: String, key: String, with relation: MiddlewareRelation, viewId: String) async throws
    func sortViewRelations(objectId: String, blockId: String, keys: [String], viewId: String) async throws
    
    @discardableResult
    func createView(objectId: String, blockId: String, view: DataviewView, source: [String]) async throws -> String
    func deleteView(objectId: String, blockId: String, viewId: String) async throws
    func addRelation(objectId: String, blockId: String, relationDetails: PropertyDetails) async throws
    func deleteRelation(objectId: String, blockId: String, relationKey: String) async throws
    func addRecord(
        typeUniqueKey: ObjectTypeUniqueKey?,
        templateId: String,
        spaceId: String,
        details: ObjectDetails
    ) async throws -> ObjectDetails
    func setPositionForView(objectId: String, blockId: String, viewId: String, position: Int) async throws
    func objectOrderUpdate(objectId: String, blockId: String, order: [DataviewObjectOrder]) async throws
    func groupOrderUpdate(objectId: String, blockId: String, viewId: String, groupOrder: DataviewGroupOrder) async throws
}
