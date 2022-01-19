import BlocksModels
import AnytypeCore

enum DataviewUpdate: Hashable {
    case set(view: DataviewView)
    case order(ids: [BlockId])
    case delete(id: BlockId)
}

enum EventsListenerUpdate: Hashable {
    case general
    case syncStatus(SyncStatus)
    case blocks(blockIds: Set<BlockId>)
    case details(id: BlockId)
    case dataview(DataviewUpdate)

    var hasUpdate: Bool {
        switch self {
        case .general, .syncStatus, .details, .dataview:
            return true
        case let .blocks(blockIds):
            return !blockIds.isEmpty
        }
    }
}
