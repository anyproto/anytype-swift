import Foundation

struct SpaceDiscussionsUnreadInfo: Hashable, Sendable {
    /// Unread messages in parents the user is subscribed to.
    /// Includes subscribed-parent mentions (a mention is also a message).
    let unreadMessageCount: Int

    /// Mentions across this space's included parents, split by subscription status.
    let mentions: SpaceDiscussionsMentions

    /// All parents contributing to this space's unread bucket — subscribed OR mention-only-unsubscribed.
    /// Sorted by lastMessageDate desc.
    let parents: [DiscussionUnreadParent]
}

struct SpaceDiscussionsMentions: Hashable, Sendable {
    /// Mentions in subscribed parents (already inside `SpaceDiscussionsUnreadInfo.unreadMessageCount`).
    /// Private — only used internally to derive `totalCount` and avoid double-counting in `.all` mode.
    private let subscribedCount: Int

    /// Mentions in parents the user is NOT subscribed to.
    /// Bumps the badge in `.all` mode (not in `unreadMessageCount`).
    let unsubscribedCount: Int

    /// Total mentions across all included parents.
    var totalCount: Int { subscribedCount + unsubscribedCount }

    init(subscribedCount: Int, unsubscribedCount: Int) {
        self.subscribedCount = subscribedCount
        self.unsubscribedCount = unsubscribedCount
    }
}

struct DiscussionUnreadParent: Hashable, Sendable {
    let id: String
    let name: String
    let lastMessageDate: Date?
    let hasUnreadMention: Bool
}
