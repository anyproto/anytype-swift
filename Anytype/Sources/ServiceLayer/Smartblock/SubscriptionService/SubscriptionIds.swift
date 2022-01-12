import BlocksModels
import Kingfisher

enum SubscriptionId: Hashable {
    case history
    case archive
    case shared
    case sets
    
    case profile(id: BlockId)
    
    
    private static let historyId = "SubscriptionId.History"
    private static let archiveId = "SubscriptionId.Archive"
    private static let sharedId = "SubscriptionId.Shared"
    private static let setsId = "SubscriptionId.Sets"
    private static let profileId = "SubscriptionId.Profile"
    
    var identifier: String {
        switch self {
        case .history:
            return Self.historyId
        case .archive:
            return Self.archiveId
        case .shared:
            return Self.sharedId
        case .sets:
            return Self.setsId
        case .profile(let id):
            return "\(Self.profileId).\(id)"
        }
    }
    
    init?(identifier: String) {
        if identifier == Self.historyId {
            self = .history
        } else if identifier == Self.archiveId {
            self = .archive
        } else if identifier == Self.setsId {
            self = .sets
        } else if identifier == Self.sharedId {
            self = .shared
        }
        
        let profileComponents = identifier.components(separatedBy: Self.profileId)
        if profileComponents.count == 2 {
            self = .profile(id: profileComponents[1])
        }
        
        
        return nil
    }
}
