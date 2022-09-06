import BlocksModels

extension Relation {
    
    struct Checkbox: RelationProtocol, Hashable {
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let isBundled: Bool
        
        let value: Bool
    }
    
}
