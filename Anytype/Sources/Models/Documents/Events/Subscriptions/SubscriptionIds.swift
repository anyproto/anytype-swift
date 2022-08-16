import BlocksModels
import Kingfisher

struct SetSubsriptionData: Hashable {
    let source: [String]
    let sorts: [DataviewSort]
    let filters: [DataviewFilter]
    let options: [DataviewRelationOption]
    let currentPage: Int64
    
    init(dataView: BlockDataview, view: DataviewView, currentPage: Int64) {
        self.source = dataView.source
        self.sorts = view.sorts
        self.filters = view.filters
        self.options = view.options
        self.currentPage = currentPage
    }
}


enum SubscriptionData: Hashable {
    case recentTab
    case archiveTab
    case sharedTab
    case setsTab
    
    case profile(id: BlockId)
    case set(SetSubsriptionData)
    
    var identifier: SubscriptionId {
        switch self {
        case .recentTab:
            return .recentTab
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
    case recentTab = "SubscriptionId.RecentTab"
    case archiveTab = "SubscriptionId.ArchiveTab"
    case sharedTab = "SubscriptionId.SharedTab"
    case setsTab = "SubscriptionId.SetsTab"

    case profile = "SubscriptionId.Profile"
    
    case set = "SubscriptionId.Set"
}
