import BlocksModels

protocol DataviewServiceProtocol {
    func updateView( _ view: DataviewView) async throws
    func createView( _ view: DataviewView) async throws
    func deleteView( _ viewId: String) async throws
    func addRelation(_ relationDetails: RelationDetails) async throws -> Bool
    func deleteRelation(relationId: BlockId) async throws
    func addRecord(objectType: String, templateId: BlockId, setFilters: [SetFilter]) async throws -> String?
    func setSource(typeObjectId: String) async throws
    func setPositionForView(_ viewId: String, position: Int) async throws
}
