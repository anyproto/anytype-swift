import BlocksModels

extension EventHandlerUpdate {
    struct Payload: Hashable {
        var addedIds: [BlockId] = []
        var deletedIds: [BlockId] = []
        var updatedIds: [BlockId] = []
        var openedToggleId: BlockId? = nil
        static var empty: Self = .init()
        
        static func merged(lhs: Self, rhs: Self) -> Self {
            .init(addedIds: lhs.addedIds + rhs.addedIds,
                  deletedIds: lhs.deletedIds + rhs.deletedIds,
                  updatedIds: lhs.updatedIds + rhs.updatedIds,
                  openedToggleId: lhs.openedToggleId ?? rhs.openedToggleId)
        }
    }
}

enum EventHandlerUpdate: Equatable {
    case general
    case update(Payload)
    
    static var specialAfterBlockShow: Self = .general
    static var empty: Self = .update(.empty)
    
    static func merged(lhs: Self, rhs: Self) -> Self {
        switch (lhs, rhs) {
        case (_, .general): return rhs
        case (.general, _): return lhs
        case let (.update(left), .update(right)): return .update(.merged(lhs: left, rhs: right))
        }
    }
    
    func merged(update: EventHandlerUpdate) -> Self {
        .merged(lhs: self, rhs: update)
    }

    var hasUpdate: Bool {
        switch self {
        case .empty: return false
        default: return true
        }
    }
}
