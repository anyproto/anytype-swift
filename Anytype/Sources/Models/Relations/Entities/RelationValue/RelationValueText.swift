import BlocksModels

extension RelationValue {
    
    struct Text: RelationValueProtocol, Hashable, Identifiable {
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
