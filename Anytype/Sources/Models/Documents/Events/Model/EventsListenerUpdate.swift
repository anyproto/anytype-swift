import BlocksModels
import AnytypeCore

enum EventsListenerUpdate: Hashable {
    case general
    case syncStatus(SyncStatus)
    case blocks(blockIds: Set<BlockId>)
    case details(id: BlockId)
    case dataSourceUpdate

    var hasUpdate: Bool {
        switch self {
        case .general, .syncStatus, .details, .dataSourceUpdate:
            return true
        case let .blocks(blockIds):
            return !blockIds.isEmpty
        }
    }
}
