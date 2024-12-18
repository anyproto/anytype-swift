struct TypeFieldsRelationsData: Identifiable {
    var id: String { relation.id }
    
    let relation: Relation
    let relationIndex: Int
    let section: TypeFieldsRelationsSection
}

enum TypeFieldsRelationsSection {
    case header
    case fieldsMenu
    
    var title: String {
        switch self {
        case .header: return Loc.header
        case .fieldsMenu: return Loc.Fields.menu
        }
    }
}
