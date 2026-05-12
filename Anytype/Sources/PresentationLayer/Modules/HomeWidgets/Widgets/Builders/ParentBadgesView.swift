import SwiftUI

struct ParentBadgesView: View {
    let badge: ParentObjectUnreadBadge

    var body: some View {
        HStack(spacing: 4) {
            if badge.hasMentions {
                MentionBadge(style: badge.notificationMode.mentionCounterStyle)
            }
            if badge.shouldShowUnreadCounter {
                CounterView(
                    count: badge.unreadMessageCount,
                    style: badge.notificationMode.unreadCounterStyle
                )
            }
        }
    }
}
