import Services
import Foundation


enum TypeFieldsRow: Identifiable, Equatable {
    case relation(TypeFieldsRelationRow)
    case header(TypeFieldsSectionRow)
    case emptyRow(TypeFieldsSectionRow)
    
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

struct TypeFieldsRelationRow: Identifiable, Equatable {
    let section: TypeFieldsSectionRow
    let relation: Relation
    let canDrag: Bool
    
    var id: String { section.id + relation.id }
}

enum TypeFieldsSectionRow: String, Identifiable, Equatable {
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
