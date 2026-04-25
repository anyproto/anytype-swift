import Foundation

enum SpaceHomepage: Equatable, Hashable {
    case empty
    case widgets
    case graph
    case object(objectId: String)

    init(rawValue: String) {
        switch rawValue {
        case "": self = .empty
        case "widgets": self = .widgets
        case "graph": self = .graph
        default: self = .object(objectId: rawValue)
        }
    }

    var rawValue: String {
        switch self {
        case .empty: return ""
        case .widgets: return "widgets"
        case .graph: return "graph"
        case .object(let id): return id
        }
    }

    /// Display fallback: treat `.empty` as `.widgets` at UI render sites.
    /// Call sites that write or inspect raw state keep using the enum as-is.
    var displayValue: SpaceHomepage {
        self == .empty ? .widgets : self
    }
}
