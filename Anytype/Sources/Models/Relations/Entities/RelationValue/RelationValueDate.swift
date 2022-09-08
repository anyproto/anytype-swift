import BlocksModels

extension RelationValue {
    
    struct Date: RelationValueProtocol, Hashable, Identifiable {
        let id: String
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let isBundled: Bool
        
        let value: DateRelationValue?
        
        var hasValue: Bool {
            value != nil
        }
    }
    
}
