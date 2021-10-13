import BlocksModels

enum EventHandlerUpdate: Hashable {
    case general
    case syncStatus(SyncStatus)
    case update(blockIds: Set<BlockId>)
    case details(DetailsData)

    var hasUpdate: Bool {
        switch self {
        case .general, .details, .syncStatus:
            return true
        case let .update(blockIds):
            return !blockIds.isEmpty
        }
    }
}
