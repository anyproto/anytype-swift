import BlocksModels
import Kingfisher


enum SubscriptionData: Hashable {
    case history
    case archive
    case shared
    case sets
    
    case profile(id: BlockId)
    
    var identifier: SubscriptionId {
        switch self {
        case .history:
            return .history
        case .archive:
            return .archive
        case .shared:
            return .shared
        case .sets:
            return .sets
        case .profile:
            return .profile
        }
    }
}

enum SubscriptionId: String {
    case history = "SubscriptionId.History"
    case archive = "SubscriptionId.Archive"
    case shared = "SubscriptionId.Shared"
    case sets = "SubscriptionId.Sets"

    case profile = "SubscriptionId.Profile"
}
