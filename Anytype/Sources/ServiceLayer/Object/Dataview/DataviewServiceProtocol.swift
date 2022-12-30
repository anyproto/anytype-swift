import BlocksModels

protocol DataviewServiceProtocol {
    func updateView( _ view: DataviewView) async throws
    func createView( _ view: DataviewView, source: [String]) async throws
    func deleteView( _ viewId: String) async throws
    func addRelation(_ relationDetails: RelationDetails) async throws -> Bool
    func deleteRelation(relationKey: String) async throws
    func addRecord(
        objectType: String,
        templateId: BlockId,
        setFilters: [SetFilter],
        relationsDetails: [RelationDetails]
    ) async throws -> String
    func setPositionForView(_ viewId: String, position: Int) async throws
    func objectOrderUpdate(viewId: String, groupObjectIds: [GroupObjectIds]) async throws
    func groupOrderUpdate(viewId: String, groupOrder: DataviewGroupOrder) async throws
}
