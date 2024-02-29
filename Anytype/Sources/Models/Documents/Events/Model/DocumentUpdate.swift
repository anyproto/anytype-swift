import Services
import AnytypeCore

enum DocumentUpdate: Hashable {
    case general
    case syncStatus(SyncStatus)
    case blocks(blockIds: Set<String>)
    case children(blockIds: Set<String>)
    case details(id: String)
    case unhandled(blockIds: Set<String>)

    var hasUpdate: Bool {
        switch self {
        case .general, .syncStatus, .details, .children:
            return true
        case let .blocks(blockIds):
            return !blockIds.isEmpty
        case .unhandled:
            return true
        }
    }
}
