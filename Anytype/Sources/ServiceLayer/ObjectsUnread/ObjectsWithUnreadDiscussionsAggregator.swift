import Foundation
import Services

enum ObjectsWithUnreadDiscussionsAggregator {

    static func aggregate(items: [ObjectDetails], myParticipantIds: Set<String>) -> [String: SpaceDiscussionsUnreadInfo] {
        var discussionsById = [String: ObjectDetails]()
        for item in items where item.resolvedLayoutValue == .discussion {
            discussionsById[item.id] = item
        }

        var parentsBySpace = [String: [DiscussionUnreadParent]]()

        for parent in items where parent.isSupportedForDiscussion {
            let mentionCount = parent.unreadMentionCount ?? 0
            let discussion = discussionsById[parent.discussionId]
            let isSubscribed = discussion?.notificationSubscribers.contains(where: myParticipantIds.contains) ?? false
            guard mentionCount > 0 || isSubscribed else { continue }

            parentsBySpace[parent.spaceId, default: []].append(
                DiscussionUnreadParent(
                    details: parent,
                    lastMessageDate: discussion?.lastMessageDate ?? parent.lastMessageDate,
                    unreadMessageCount: parent.unreadMessageCount ?? 0,
                    unreadMentionCount: mentionCount,
                    isSubscribed: isSubscribed
                )
            )
        }

        var result = [String: SpaceDiscussionsUnreadInfo]()
        for (spaceId, parents) in parentsBySpace {
            let sorted = parents.sorted { (lhs: DiscussionUnreadParent, rhs: DiscussionUnreadParent) -> Bool in
                (lhs.lastMessageDate ?? .distantPast) > (rhs.lastMessageDate ?? .distantPast)
            }
            result[spaceId] = SpaceDiscussionsUnreadInfo(parents: sorted)
        }
        return result
    }
}
