import BlocksModels
import Kingfisher


enum SubscriptionData: Hashable {
    case historyTab
    case archiveTab
    case sharedTab
    case setsTab
    
    case profile(id: BlockId)
    case set(source: [String], sorts: [DataviewSort], filters: [DataviewFilter], relations: [DataviewViewRelation])
    
    var identifier: SubscriptionId {
        switch self {
        case .historyTab:
            return .historyTab
        case .archiveTab:
            return .archiveTab
        case .sharedTab:
            return .sharedTab
        case .setsTab:
            return .setsTab
        case .profile:
            return .profile
        case .set:
            return .set
        }
    }
}

enum SubscriptionId: String {
    case historyTab = "SubscriptionId.HistoryTab"
    case archiveTab = "SubscriptionId.ArchiveTab"
    case sharedTab = "SubscriptionId.SharedTab"
    case setsTab = "SubscriptionId.SetsTab"

    case profile = "SubscriptionId.Profile"
    
    case set = "SubscriptionId.Set"
}
