import Foundation
import BlocksModels

enum SearchNewRelationSectionType: Hashable, Identifiable {
    case createNewRelation
    case addFromLibriry([RelationMetadata])

    var id: Self { self }

    var headerName: String {
        switch self {
        case .createNewRelation: return ""
        case .addFromLibriry: return Loc.yourLibrary
        }
    }
}
