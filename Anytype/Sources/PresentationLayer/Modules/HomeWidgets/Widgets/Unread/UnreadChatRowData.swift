import Foundation
import Services

struct UnreadChatRowData: Identifiable, Equatable {
    let id: String
    let spaceId: String
    let name: String
    let icon: Icon?
    let unreadCounter: Int
    let mentionCounter: Int
    let hasUnreadReactions: Bool
    let notificationMode: SpacePushNotificationsMode
    let lastMessageDate: Date?

    var hasMentions: Bool { mentionCounter > 0 }
    var muted: Bool { notificationMode != .all }
    var shouldShowUnreadCounter: Bool {
        notificationMode.shouldShowUnreadCounter(unreadCount: unreadCounter)
    }
}
