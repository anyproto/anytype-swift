import Services
import AnytypeCore

enum DocumentUpdate: Hashable {
    case general
    case block(blockId: String)
    case details(id: String)
    case unhandled(blockId: String)
    case restrictions
    case close
    case syncStatus
    case relationDetails
}

extension DocumentUpdate {
    var isBlock: Bool {
        switch self {
        case .block(blockId: _):
            return true
        default:
            return false
        }
    }
}
