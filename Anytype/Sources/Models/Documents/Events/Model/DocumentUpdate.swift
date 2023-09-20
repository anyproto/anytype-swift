import Services
import AnytypeCore

enum DocumentUpdate: Hashable {
    case general
    case syncStatus(SyncStatus)
    case blocks(blockIds: Set<BlockId>)
    case children(blockIds: Set<BlockId>)
    case details(id: BlockId)
    case unhandled(blockIds: Set<BlockId>)

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
