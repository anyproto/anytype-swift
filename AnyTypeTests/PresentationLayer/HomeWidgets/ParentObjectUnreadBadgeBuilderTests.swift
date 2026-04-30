import Testing
@testable import Anytype
import Services

@MainActor
struct ParentObjectUnreadBadgeBuilderTests {

    private let sut = ParentObjectUnreadBadgeBuilder()

    @Test func build_copiesAllParentCounters() {
        let parent = makeParent(unreadMessageCount: 7, unreadMentionCount: 3, isSubscribed: true)
        let badge = sut.build(parent: parent, spaceView: makeSpaceView(pushMode: .all))

        #expect(badge.unreadMessageCount == 7)
        #expect(badge.unreadMentionCount == 3)
        #expect(badge.isSubscribed == true)
        #expect(badge.notificationMode == .all)
    }

    @Test func build_unsubscribedParent_carriesIsSubscribedFalse() {
        let parent = makeParent(unreadMessageCount: 5, unreadMentionCount: 2, isSubscribed: false)
        let badge = sut.build(parent: parent, spaceView: makeSpaceView(pushMode: .mentions))

        #expect(badge.isSubscribed == false)
        #expect(badge.notificationMode == .mentions)
    }

    @Test func build_picksSpaceLevelMode_notPerObjectOverride() {
        // Parents follow space-level notification mode only — forceMute/forceAll/forceMention overrides
        // (used by chats via effectiveNotificationMode) must NOT affect parent badges.
        let parent = makeParent(unreadMessageCount: 1, unreadMentionCount: 0, isSubscribed: true)
        let spaceView = makeSpaceView(pushMode: .all, forceMuteIds: [parent.id])

        let badge = sut.build(parent: parent, spaceView: spaceView)

        #expect(badge.notificationMode == .all)
    }

    @Test func build_nilSpaceView_defaultsToModeAll() {
        let parent = makeParent(unreadMessageCount: 1, unreadMentionCount: 0, isSubscribed: true)
        let badge = sut.build(parent: parent, spaceView: nil)

        #expect(badge.notificationMode == .all)
    }

    @Test func build_modeNothing_propagates() {
        let parent = makeParent(unreadMessageCount: 1, unreadMentionCount: 0, isSubscribed: true)
        let badge = sut.build(parent: parent, spaceView: makeSpaceView(pushMode: .nothing))

        #expect(badge.notificationMode == .nothing)
    }

    // MARK: - Fixtures

    private func makeParent(
        id: String = "parent-1",
        unreadMessageCount: Int,
        unreadMentionCount: Int,
        isSubscribed: Bool
    ) -> DiscussionUnreadParent {
        DiscussionUnreadParent(
            details: ObjectDetails(id: id, values: [:]),
            lastMessageDate: nil,
            unreadMessageCount: unreadMessageCount,
            unreadMentionCount: unreadMentionCount,
            isSubscribed: isSubscribed
        )
    }

    private func makeSpaceView(
        pushMode: SpacePushNotificationsMode,
        forceAllIds: [String] = [],
        forceMuteIds: [String] = [],
        forceMentionIds: [String] = []
    ) -> SpaceView {
        SpaceView(
            id: "view-1",
            name: "",
            description: "",
            objectIconImage: .object(.space(.name(name: "", iconOption: 0, circular: false))),
            targetSpaceId: "space-1",
            createdDate: nil,
            joinDate: nil,
            accountStatus: .spaceActive,
            localStatus: .ok,
            spaceAccessType: nil,
            readersLimit: nil,
            writersLimit: nil,
            chatId: "",
            spaceOrder: "",
            uxType: .data,
            spaceType: .regular,
            pushNotificationEncryptionKey: "",
            pushNotificationMode: pushMode,
            forceAllIds: forceAllIds,
            forceMuteIds: forceMuteIds,
            forceMentionIds: forceMentionIds,
            oneToOneIdentity: "",
            homepage: .empty
        )
    }
}
