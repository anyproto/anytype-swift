import Services
import Foundation


enum TypePropertiesRow: Identifiable, Equatable {
    case relation(TypePropertiesRelationRow)
    case header(TypePropertiesSectionRow)
    case emptyRow(TypePropertiesSectionRow)
    
    var id: String {
        switch self {
        case .relation(let relation):
            relation.id
        case .header(let section):
            section.id
        case .emptyRow(let section):
            "emptyRow" + section.id
        }
    }
    
    var relationId: String? {
        switch self {
        case .relation(let relationRow):
            relationRow.relation.id
        case .header, .emptyRow:
            nil
        }
    }
}

struct TypePropertiesRelationRow: Identifiable, Equatable {
    let section: TypePropertiesSectionRow
    let relation: Relation
    let canDrag: Bool
    
    var id: String { section.id + relation.id }
}

enum TypePropertiesSectionRow: String, Identifiable, Equatable {
    case header
    case fieldsMenu
    case hidden
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .header: return Loc.header
        case .fieldsMenu: return Loc.Fields.menu
        case .hidden: return Loc.hidden
        }
    }
    
    var isFeatured: Bool {
        switch self {
        case .header:
            true
        case .fieldsMenu, .hidden:
            false
        }
    }
    
    var canCreateRelations: Bool {
        switch self {
        case .hidden, .header:
            false
        case .fieldsMenu:
            true
        }
    }
    
    var analyticsValue: String {
        switch self {
        case .header:
            return "Featured"
        case .fieldsMenu:
            return "Recommended"
        case .hidden:
            return "Hidden"
        }
    }
}
