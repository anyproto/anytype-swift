import Foundation
import Services

struct UnreadSectionRowData: Identifiable, Equatable {
    let id: String
    let details: ObjectDetails
    let notificationMode: SpacePushNotificationsMode
    let unreadMessageCount: Int
    let unreadMentionCount: Int
    let hasUnreadReactions: Bool
    let isSubscribed: Bool
    let lastMessageDate: Date?
}
