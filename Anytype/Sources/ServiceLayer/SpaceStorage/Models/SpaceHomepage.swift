import Foundation

enum SpaceHomepage: Equatable, Hashable {
    case empty
    case widgets
    case object(objectId: String)

    init(rawValue: String) {
        switch rawValue {
        case "": self = .empty
        case "widgets": self = .widgets
        default: self = .object(objectId: rawValue)
        }
    }

    var rawValue: String {
        switch self {
        case .empty: return ""
        case .widgets: return "widgets"
        case .object(let id): return id
        }
    }
}
