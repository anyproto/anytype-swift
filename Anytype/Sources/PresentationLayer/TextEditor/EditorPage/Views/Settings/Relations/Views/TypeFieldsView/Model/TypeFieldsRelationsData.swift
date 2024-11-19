struct TypeFieldsRelationsData: Identifiable {
    var id: String { relation.id }
    
    let relation: Relation
    
    let relationIndex: Int
    let sectionIndex: Int
    let sectionTitle: String
}
