import Foundation
import SwiftUI
import Services

struct ParentObjectUnreadBadge: Equatable, Hashable {
    let unreadMessageCount: Int
    let unreadMentionCount: Int
    let isSubscribed: Bool
    let notificationMode: SpacePushNotificationsMode

    var hasMentions: Bool { unreadMentionCount > 0 }
    var muted: Bool { notificationMode != .all }

    var shouldShowUnreadCounter: Bool {
        notificationMode.shouldShowUnreadCounter(unreadCount: unreadMessageCount, isSubscribed: isSubscribed)
    }

    var hasVisibleCounters: Bool { hasMentions || shouldShowUnreadCounter }

    var titleColor: Color { notificationMode == .nothing ? .Text.secondary : .Text.primary }
}
