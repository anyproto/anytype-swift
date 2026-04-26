import Foundation
import Services

struct ParentObjectUnreadEntry: Hashable, Sendable {
    let details: ObjectDetails
    let lastMessageDate: Date?
    let badge: UnreadBadge

    var id: String { details.id }
    var spaceId: String { details.spaceId }
    var name: String { details.name }
    var lastUpdate: Date? { lastMessageDate ?? details.lastModifiedDate }
    var unreadCount: Int { badge.unreadCounter?.messageCount ?? 0 }
    var hasMention: Bool { badge.hasMention }
}
