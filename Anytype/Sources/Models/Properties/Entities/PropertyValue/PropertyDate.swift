import Services

extension Property {
    
    struct Date: PropertyProtocol, Hashable, Identifiable {
        let id: String
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let canBeRemovedFromObject: Bool
        let isDeleted: Bool
        
        let value: DatePropertyValue?
        
        var hasValue: Bool {
            value != nil
        }
    }
    
}
