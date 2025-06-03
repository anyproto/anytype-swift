import Services

extension Relation {
    
    struct Checkbox: PropertyProtocol, Hashable, Identifiable {
        let id: String
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let canBeRemovedFromObject: Bool
        let isDeleted: Bool
        
        let value: Bool
        
        var hasValue: Bool {
            return true
        }
    }
    
}
