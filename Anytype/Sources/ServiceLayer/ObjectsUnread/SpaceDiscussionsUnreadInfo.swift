import Foundation
import Services

struct SpaceDiscussionsUnreadInfo: Hashable, Sendable {
    /// All parents contributing to this space's unread bucket — subscribed OR mention-only-unsubscribed.
    /// Sorted by lastMessageDate desc.
    let parents: [DiscussionUnreadParent]

    /// Sum of `unreadMessageCount` across subscribed parents.
    /// Subscribed-parent mentions are part of these messages (a mention is also a message).
    var unreadMessageCount: Int {
        parents.lazy.filter(\.isSubscribed).map(\.unreadMessageCount).reduce(0, +)
    }

    /// Mentions in parents the user is NOT subscribed to.
    /// These aren't included in `unreadMessageCount`, so they bump badge totals in `.all` mode.
    var unsubscribedMentionCount: Int {
        parents.lazy.filter { !$0.isSubscribed }.map(\.unreadMentionCount).reduce(0, +)
    }

    /// All mentions across all included parents (subscribed + unsubscribed).
    var totalMentionCount: Int {
        parents.lazy.map(\.unreadMentionCount).reduce(0, +)
    }
}

struct DiscussionUnreadParent: Hashable, Sendable {
    let details: ObjectDetails
    let lastMessageDate: Date?
    let unreadMessageCount: Int
    let unreadMentionCount: Int
    let isSubscribed: Bool

    var id: String { details.id }
    var spaceId: String { details.spaceId }
    var name: String { details.objectName }
    var hasUnreadMention: Bool { unreadMentionCount > 0 }
}
