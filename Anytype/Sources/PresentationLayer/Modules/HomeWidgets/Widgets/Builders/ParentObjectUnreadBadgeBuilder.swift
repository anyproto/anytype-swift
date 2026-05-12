import Foundation
import Services

@MainActor
protocol ParentObjectUnreadBadgeBuilderProtocol: AnyObject, Sendable {
    func build(parent: DiscussionUnreadParent, spaceView: SpaceView?) -> ParentObjectUnreadBadge
}

@MainActor
final class ParentObjectUnreadBadgeBuilder: ParentObjectUnreadBadgeBuilderProtocol, Sendable {

    func build(parent: DiscussionUnreadParent, spaceView: SpaceView?) -> ParentObjectUnreadBadge {
        ParentObjectUnreadBadge(
            unreadMessageCount: parent.unreadMessageCount,
            unreadMentionCount: parent.unreadMentionCount,
            isSubscribed: parent.isSubscribed,
            notificationMode: spaceView?.pushNotificationMode ?? .all
        )
    }
}
