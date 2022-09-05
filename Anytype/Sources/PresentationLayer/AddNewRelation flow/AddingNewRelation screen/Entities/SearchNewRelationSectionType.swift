import Foundation
import BlocksModels

enum SearchNewRelationSectionType: Hashable, Identifiable {
    case createNewRelation
    case addFromLibriry([RelationDetails])

    var id: Self { self }

    var headerName: String {
        switch self {
        case .createNewRelation: return ""
        case .addFromLibriry: return Loc.yourLibrary
        }
    }
}
