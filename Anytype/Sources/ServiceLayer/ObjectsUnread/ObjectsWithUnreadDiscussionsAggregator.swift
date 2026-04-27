import Foundation
import Services

enum ObjectsWithUnreadDiscussionsAggregator {

    static func aggregate(items: [ObjectDetails], myParticipantIds: Set<String>) -> [String: SpaceDiscussionsUnreadInfo] {
        var discussionsById = [String: ObjectDetails]()
        for item in items where item.resolvedLayoutValue == .discussion {
            discussionsById[item.id] = item
        }

        var countsBySpace = [String: (messages: Int, mentions: Int)]()
        var parentsBySpace = [String: [DiscussionUnreadParent]]()

        for parent in items where parent.isSupportedForDiscussion {
            let mentionCount = parent.unreadMentionCount ?? 0
            let discussion = discussionsById[parent.discussionId]
            let isSubscribed = discussion?.notificationSubscribers.contains(where: myParticipantIds.contains) ?? false
            guard mentionCount > 0 || isSubscribed else { continue }

            let messageCount = isSubscribed ? (parent.unreadMessageCount ?? 0) : 0
            let existing = countsBySpace[parent.spaceId] ?? (0, 0)
            countsBySpace[parent.spaceId] = (
                existing.messages + messageCount,
                existing.mentions + mentionCount
            )
            parentsBySpace[parent.spaceId, default: []].append(
                DiscussionUnreadParent(
                    id: parent.id,
                    name: parent.objectName,
                    lastMessageDate: discussion?.lastMessageDate ?? parent.lastMessageDate
                )
            )
        }

        var result = [String: SpaceDiscussionsUnreadInfo]()
        for (spaceId, counts) in countsBySpace {
            let parents = (parentsBySpace[spaceId] ?? []).sorted { (lhs: DiscussionUnreadParent, rhs: DiscussionUnreadParent) -> Bool in
                (lhs.lastMessageDate ?? .distantPast) > (rhs.lastMessageDate ?? .distantPast)
            }
            result[spaceId] = SpaceDiscussionsUnreadInfo(
                unreadMessageCount: counts.messages,
                unreadMentionCount: counts.mentions,
                parents: parents
            )
        }
        return result
    }
}
