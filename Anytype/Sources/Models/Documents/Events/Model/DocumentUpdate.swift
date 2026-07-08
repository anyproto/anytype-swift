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

    // Mention texts and indentation/numbered-list metadata are rebuilt only when
    // blocks change; mention texts also depend on details of mentioned objects.
    var affectsBlocks: Bool {
        switch self {
        case .general, .block, .unhandled:
            return true
        default:
            return false
        }
    }

    var affectsDetails: Bool {
        switch self {
        case .details:
            return true
        default:
            return false
        }
    }
}
