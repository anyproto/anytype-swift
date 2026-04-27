import Foundation

struct SpaceDiscussionsUnreadInfo: Hashable, Sendable {
    let unreadMessageCount: Int
    let unreadMentionCount: Int
    let parents: [DiscussionUnreadParent]
}

struct DiscussionUnreadParent: Hashable, Sendable {
    let id: String
    let name: String
    let lastMessageDate: Date?
}
