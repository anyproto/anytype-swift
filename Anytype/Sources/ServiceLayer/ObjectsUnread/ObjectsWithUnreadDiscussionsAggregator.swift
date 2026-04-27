import Foundation
import Services

enum ObjectsWithUnreadDiscussionsAggregator {

    private struct SpaceCounters {
        var messages: Int = 0
        var subscribedMentions: Int = 0
        var unsubscribedMentions: Int = 0
    }

    static func aggregate(items: [ObjectDetails], myParticipantIds: Set<String>) -> [String: SpaceDiscussionsUnreadInfo] {
        var discussionsById = [String: ObjectDetails]()
        for item in items where item.resolvedLayoutValue == .discussion {
            discussionsById[item.id] = item
        }

        var countsBySpace = [String: SpaceCounters]()
        var parentsBySpace = [String: [DiscussionUnreadParent]]()

        for parent in items where parent.isSupportedForDiscussion {
            let mentionCount = parent.unreadMentionCount ?? 0
            let discussion = discussionsById[parent.discussionId]
            let isSubscribed = discussion?.notificationSubscribers.contains(where: myParticipantIds.contains) ?? false
            guard mentionCount > 0 || isSubscribed else { continue }

            var counters = countsBySpace[parent.spaceId] ?? SpaceCounters()
            if isSubscribed {
                counters.messages += parent.unreadMessageCount ?? 0
                counters.subscribedMentions += mentionCount
            } else {
                counters.unsubscribedMentions += mentionCount
            }
            countsBySpace[parent.spaceId] = counters

            parentsBySpace[parent.spaceId, default: []].append(
                DiscussionUnreadParent(
                    id: parent.id,
                    name: parent.objectName,
                    lastMessageDate: discussion?.lastMessageDate ?? parent.lastMessageDate,
                    hasUnreadMention: mentionCount > 0
                )
            )
        }

        var result = [String: SpaceDiscussionsUnreadInfo]()
        for (spaceId, counters) in countsBySpace {
            let parents = (parentsBySpace[spaceId] ?? []).sorted { (lhs: DiscussionUnreadParent, rhs: DiscussionUnreadParent) -> Bool in
                (lhs.lastMessageDate ?? .distantPast) > (rhs.lastMessageDate ?? .distantPast)
            }
            result[spaceId] = SpaceDiscussionsUnreadInfo(
                unreadMessageCount: counters.messages,
                mentions: SpaceDiscussionsMentions(
                    subscribedCount: counters.subscribedMentions,
                    unsubscribedCount: counters.unsubscribedMentions
                ),
                parents: parents
            )
        }
        return result
    }
}
