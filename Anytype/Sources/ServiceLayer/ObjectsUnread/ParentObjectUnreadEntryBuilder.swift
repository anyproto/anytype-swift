import Foundation
import Services

enum ParentObjectUnreadEntryBuilder {

    /// Builds an unread entry for a discussion + its parent object, applying the visibility
    /// rules from the plan's truth table. Returns nil for the rows the server filter excludes
    /// (rows 3 and 7 — !subscribed AND no mention) so the service can drop them safely.
    static func makeEntry(
        discussion: ObjectDetails,
        parent: ObjectDetails,
        myParticipantId: String?,
        spaceMuted: Bool
    ) -> ParentObjectUnreadEntry? {
        let isSubscribed = myParticipantId
            .map(discussion.notificationSubscribers.contains) ?? false
        let unread = discussion.unreadMessageCount ?? 0
        let mention = discussion.unreadMentionCount ?? 0

        guard isSubscribed || mention > 0 else { return nil }

        let unreadCounter: UnreadBadge.UnreadCounter? = (isSubscribed && unread > 0)
            ? .init(messageCount: unread, style: spaceMuted ? .grey : .blue)
            : nil

        return ParentObjectUnreadEntry(
            details: parent,
            lastMessageDate: discussion.lastMessageDate,
            badge: UnreadBadge(unreadCounter: unreadCounter, hasMention: mention > 0)
        )
    }
}
