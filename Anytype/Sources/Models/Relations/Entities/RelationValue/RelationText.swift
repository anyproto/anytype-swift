import BlocksModels

extension Relation {
    
    struct Text: RelationProtocol, Hashable, Identifiable {
        let id: String
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let isBundled: Bool
        
        let value: String?
        
        var hasValue: Bool {
            value?.isNotEmpty ?? false
        }
    }
    
}
