import BlocksModels

extension Relation {
    
    struct Text: RelationProtocol, Hashable, Identifiable {
        let id: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let isBundled: Bool
        
        let value: String?
    }
    
}
