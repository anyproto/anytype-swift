import Services
import AnytypeCore

enum DocumentUpdate: Hashable {
    case general
    case syncStatus(SyncStatus)
    case block(blockId: String)
    case children(blockId: String)
    case details(id: String)
    case unhandled(blockId: String)
}
