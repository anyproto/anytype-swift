import BlocksModels
import AnytypeCore

enum DocumentUpdate: Hashable {
    case general
    case syncStatus(SyncStatus)
    case blocks(blockIds: Set<BlockId>)
    case details(id: BlockId)
    case dataSourceUpdate
    case header(ObjectHeaderUpdate)
    case changeType(objectTypeURL: String)

    var hasUpdate: Bool {
        switch self {
        case .general, .syncStatus, .details, .dataSourceUpdate, .header, .changeType:
            return true
        case let .blocks(blockIds):
            return !blockIds.isEmpty
        }
    }
}
