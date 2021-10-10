import BlocksModels

enum EventHandlerUpdate: Hashable {
    case general
    case update(blockIds: Set<BlockId>)
    case details(ObjectDetails)

    var hasUpdate: Bool {
        switch self {
        case .general:
            return true
        case .details:
            return true
        case let .update(blockIds):
            return !blockIds.isEmpty
        }
    }
}
