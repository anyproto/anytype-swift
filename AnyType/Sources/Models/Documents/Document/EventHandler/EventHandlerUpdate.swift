
import BlocksModels

enum EventHandlerUpdate {
    case general
    case update(EventHandlerUpdatePayload)
    
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
        case .general:
            return true
        case let .update(update):
            return update.hasUpdates
        }
    }
}
