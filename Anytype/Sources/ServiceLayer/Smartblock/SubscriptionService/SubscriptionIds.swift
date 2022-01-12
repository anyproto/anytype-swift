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
    private static let idSeparator = "|||"
    
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
            return "\(Self.profileId)\(Self.idSeparator)\(id)"
        }
    }
    
    init?(identifier: String) {
        switch identifier {
        case Self.historyId:
            self = .history
        case Self.archiveId:
            self = .archive
        case Self.setsId:
            self = .sets
        case Self.sharedId:
            self = .shared
        default:
            let profileComponents = identifier.components(separatedBy: Self.idSeparator)
            if profileComponents.count == 2 {
                self = .profile(id: profileComponents[1])
            } else {
                return nil
            }
        }
    }
}
