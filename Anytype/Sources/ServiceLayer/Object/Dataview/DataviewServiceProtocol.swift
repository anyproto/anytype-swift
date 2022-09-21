import BlocksModels

protocol DataviewServiceProtocol {
    func updateView( _ view: DataviewView) async throws
    func createView( _ view: DataviewView) async throws
    func deleteView( _ viewId: String) async throws
    func addRelation(_ relation: RelationMetadata) -> Bool
    func deleteRelation(key: BlockId)
    func addRecord(templateId: BlockId, setFilters: [SetFilter]) async throws -> ObjectDetails?
    func setSource(typeObjectId: String) async throws
    func setPositionForView(_ viewId: String, position: Int) async throws
}
