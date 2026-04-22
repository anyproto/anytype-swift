import Foundation

enum DiscussionNotificationMode: Hashable {
    case allNewReplies
    case mentionsOnly

    var title: String {
        switch self {
        case .allNewReplies:
            Loc.Discussion.Notifications.allNewReplies
        case .mentionsOnly:
            Loc.Discussion.Notifications.mentionsOnly
        }
    }
}
