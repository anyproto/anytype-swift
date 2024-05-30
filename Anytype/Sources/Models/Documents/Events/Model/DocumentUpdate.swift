import Services
import AnytypeCore

enum DocumentUpdate: Hashable {
    case general
    case syncStatus
    case block(blockId: String)
    case children(blockId: String)
    case details(id: String)
    case unhandled(blockId: String)
}

extension DocumentUpdate {
    var isChildren: Bool {
        switch self {
        case .children(blockId: _):
            return true
        default:
            return false
        }
    }
}
