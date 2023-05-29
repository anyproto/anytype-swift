import BlocksModels

extension Relation {
    
    struct Date: RelationProtocol, Hashable, Identifiable {
        let id: String
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let isSystem: Bool
        let isDeleted: Bool
        
        let value: DateRelationValue?
        
        var hasValue: Bool {
            value != nil
        }
    }
    
}
