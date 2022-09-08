import BlocksModels

extension RelationValue {
    
    struct Checkbox: RelationValueProtocol, Hashable, Identifiable {
        let id: String
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let isBundled: Bool
        
        let value: Bool
        
        var hasValue: Bool {
            return true
        }
    }
    
}
