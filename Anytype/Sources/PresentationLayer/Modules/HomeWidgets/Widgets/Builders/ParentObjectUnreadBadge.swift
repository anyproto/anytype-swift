import Foundation
import SwiftUI
import Services
import AnytypeCore

struct ParentObjectUnreadBadge: Equatable, Hashable {
    let unreadMessageCount: Int
    let unreadMentionCount: Int
    let isSubscribed: Bool
    let notificationMode: SpacePushNotificationsMode

    var hasMentions: Bool { unreadMentionCount > 0 }
    var muted: Bool { notificationMode != .all }

    /// Mention-only (unsubscribed) parents never show the counter pill regardless of muteAndHide.
    /// Subscribed parents follow the same chat rule: hidden in `.nothing` mode when muteAndHide is on.
    var shouldShowUnreadCounter: Bool {
        guard isSubscribed, unreadMessageCount > 0 else { return false }
        guard FeatureFlags.muteAndHide else { return true }
        return notificationMode != .nothing
    }

    var hasVisibleCounters: Bool { hasMentions || shouldShowUnreadCounter }

    var titleColor: Color { notificationMode == .nothing ? .Text.secondary : .Text.primary }
}
