import Foundation

// A filter applied to the unified search, rendered as a removable pill inside the
// search input. At most one token per group; adding another replaces it in place.
// Persisted by value - display data (space name/icon, ...) is resolved from stores
// on restore, and unresolvable tokens are dropped silently.
enum UnifiedSearchToken: Equatable, Hashable, Codable, Identifiable {
    case space(spaceId: String)

    enum Group: Equatable {
        case scope
    }

    var id: String {
        switch self {
        case .space(let spaceId):
            "space:\(spaceId)"
        }
    }

    var group: Group {
        switch self {
        case .space:
            .scope
        }
    }
}
