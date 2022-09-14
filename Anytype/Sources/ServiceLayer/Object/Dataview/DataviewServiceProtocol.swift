import BlocksModels

protocol DataviewServiceProtocol {
    func updateView( _ view: DataviewView)
    func createView( _ view: DataviewView)
    func deleteView( _ viewId: String)
    func addRelation(_ relationDetails: RelationDetails) -> Bool
    func deleteRelation(relationId: BlockId)
    func addRecord(objectType: String, templateId: BlockId, setFilters: [SetFilter]) -> String?
    func setSource(typeObjectId: String)
    func setPositionForView(_ viewId: String, position: Int)
}
