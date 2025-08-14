import Services

extension Property {
    
    struct Text: PropertyProtocol, Hashable, Identifiable {
        let id: String
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let canBeRemovedFromObject: Bool
        let isDeleted: Bool
        let isDeletedValue: Bool
        
        let value: String?
        
        init(
            id: String,
            key: String,
            name: String,
            isFeatured: Bool,
            isEditable: Bool, 
            canBeRemovedFromObject: Bool,
            isDeleted: Bool,
            isDeletedValue: Bool = false,
            value: String?
        ) {
            self.id = id
            self.key = key
            self.name = name
            self.isFeatured = isFeatured
            self.isEditable = isEditable
            self.canBeRemovedFromObject = canBeRemovedFromObject
            self.isDeleted = isDeleted
            self.isDeletedValue = isDeletedValue
            self.value = value
        }
        
        var hasValue: Bool {
            value?.isNotEmpty ?? false
        }
    }
    
}
