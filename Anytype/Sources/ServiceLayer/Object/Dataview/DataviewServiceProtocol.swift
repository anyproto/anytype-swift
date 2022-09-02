import BlocksModels

protocol DataviewServiceProtocol {
    func updateView( _ view: DataviewView)
    func addRelation(_ relation: RelationInfo) -> Bool
    func deleteRelation(relationId: BlockId)
    func addRecord(templateId: BlockId, setFilters: [SetFilter]) -> ObjectDetails?
}
