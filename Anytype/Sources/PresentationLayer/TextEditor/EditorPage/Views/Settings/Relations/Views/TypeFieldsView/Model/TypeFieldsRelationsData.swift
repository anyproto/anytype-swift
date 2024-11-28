import Services

enum TypeFieldsRelationsDataMode: Identifiable {
    case relation(RelationDetails)
    case stub
    
    var id: String {
        switch self {
        case .relation(let relationDetails):
            relationDetails.id
        case .stub:
            "stub"
        }
    }
}

struct TypeFieldsRelationsData: Identifiable {
    var id: String { section.id + data.id }
    
    let data: TypeFieldsRelationsDataMode
    let relationIndex: Int
    let section: TypeFieldsRelationsSection
    
    var canBeRemovedFromObject: Bool {
        switch data {
        case .relation(let relationDetails):
            relationDetails.canBeRemovedFromObject
        case .stub:
            false
        }
    }
    
    var key: String? {
        switch data {
        case .relation(let relationDetails):
            relationDetails.key
        case .stub:
            nil
        }
    }
    
    var relationId: String? {
        switch data {
        case .relation(let relationDetails):
            relationDetails.id
        case .stub:
            nil
        }
    }
}

enum TypeFieldsRelationsSection: String, Identifiable {
    case header
    case fieldsMenu
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .header: return Loc.header
        case .fieldsMenu: return Loc.Fields.menu
        }
    }
}
