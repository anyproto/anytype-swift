import Services

protocol DataviewServiceProtocol {
    func updateView(_ view: DataviewView) async throws
    
    // MARK: - Filters
    func addFilter(_ filter: DataviewFilter, viewId: String) async throws
    func removeFilters(_ ids: [String], viewId: String) async throws
    func replaceFilter(_ id: String, with filter: DataviewFilter, viewId: String) async throws
    
    // MARK: - Sorts
    func addSort(_ sort: DataviewSort, viewId: String) async throws
    func removeSorts(_ ids: [String], viewId: String) async throws
    func replaceSort(_ id: String, with sort: DataviewSort, viewId: String) async throws
    func sortSorts(_ ids: [String], viewId: String) async throws
    
    // MARK: - Relations
    func addViewRelation(_ relation: MiddlewareRelation, viewId: String) async throws
    func removeViewRelations(_ keys: [String], viewId: String) async throws
    func replaceViewRelation(_ key: String, with relation: MiddlewareRelation, viewId: String) async throws
    func sortViewRelations(_ keys: [String], viewId: String) async throws
    
    func createView(_ view: DataviewView, source: [String]) async throws
    func deleteView(_ viewId: String) async throws
    func addRelation(_ relationDetails: RelationDetails) async throws
    func deleteRelation(relationKey: String) async throws
    func addRecord(
        objectType: String,
        shouldSelectType: Bool,
        templateId: BlockId,
        setFilters: [SetFilter],
        relationsDetails: [RelationDetails]
    ) async throws -> ObjectDetails
    func setPositionForView(_ viewId: String, position: Int) async throws
    func objectOrderUpdate(viewId: String, groupObjectIds: [GroupObjectIds]) async throws
    func groupOrderUpdate(viewId: String, groupOrder: DataviewGroupOrder) async throws
}
