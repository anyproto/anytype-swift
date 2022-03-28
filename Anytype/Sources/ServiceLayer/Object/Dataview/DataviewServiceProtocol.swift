import BlocksModels

protocol DataviewServiceProtocol {
    func updateView( _ view: DataviewView)
    func addRelation(_ relation: RelationMetadata) -> Bool
}
