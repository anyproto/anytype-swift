import Testing
import Foundation
@testable import Anytype
import Services

struct SpaceHubSpacesStorageVisibleParentsTests {

    @Test func mutedMultichat_keepsOnlyMentionParents() {
        let space = makeSpace(spaceType: .regular, mode: .nothing)
        let mentionParent = makeParent(id: "p-mention", unreadMessageCount: 0, unreadMentionCount: 1)
        let messageOnly = makeParent(id: "p-message", unreadMessageCount: 1, unreadMentionCount: 0)

        let result = SpaceHubSpacesStorage.filterVisibleDiscussionParents(
            [mentionParent, messageOnly],
            spaceView: space
        )

        #expect(result.map(\.id) == ["p-mention"])
    }

    @Test func allMode_keepsAllParentsWithCounters() {
        let space = makeSpace(spaceType: .regular, mode: .all)
        let mentionParent = makeParent(id: "p-mention", unreadMessageCount: 0, unreadMentionCount: 1)
        let messageOnly = makeParent(id: "p-message", unreadMessageCount: 1, unreadMentionCount: 0)

        let result = SpaceHubSpacesStorage.filterVisibleDiscussionParents(
            [mentionParent, messageOnly],
            spaceView: space
        )

        #expect(result.map(\.id) == ["p-mention", "p-message"])
    }

    @Test func mentionsMode_keepsAllParentsWithCounters() {
        let space = makeSpace(spaceType: .regular, mode: .mentions)
        let mentionParent = makeParent(id: "p-mention", unreadMessageCount: 0, unreadMentionCount: 1)
        let messageOnly = makeParent(id: "p-message", unreadMessageCount: 1, unreadMentionCount: 0)

        let result = SpaceHubSpacesStorage.filterVisibleDiscussionParents(
            [mentionParent, messageOnly],
            spaceView: space
        )

        #expect(result.map(\.id) == ["p-mention", "p-message"])
    }

    @Test func oneToOneMuted_keepsAllParentsWithCounters() {
        // 1:1 spaces are excluded from the muted-hide path.
        let space = makeSpace(spaceType: .oneToOne, mode: .nothing)
        let mentionParent = makeParent(id: "p-mention", unreadMessageCount: 0, unreadMentionCount: 1)
        let messageOnly = makeParent(id: "p-message", unreadMessageCount: 1, unreadMentionCount: 0)

        let result = SpaceHubSpacesStorage.filterVisibleDiscussionParents(
            [mentionParent, messageOnly],
            spaceView: space
        )

        #expect(result.map(\.id) == ["p-mention", "p-message"])
    }

    @Test func anyMode_dropsFullyCaughtUpSubscribedParent() {
        // Aggregator admits subscribed parents even with zero counters; the visible filter must drop them
        // so the multichat preview never shows a name with no badge.
        let caughtUp = makeParent(id: "p-caughtup", unreadMessageCount: 0, unreadMentionCount: 0)

        for mode: SpacePushNotificationsMode in [.all, .mentions, .nothing] {
            let space = makeSpace(spaceType: .regular, mode: mode)
            let result = SpaceHubSpacesStorage.filterVisibleDiscussionParents([caughtUp], spaceView: space)
            #expect(result.isEmpty)
        }
    }

    @Test func emptyInput_returnsEmpty() {
        let space = makeSpace(spaceType: .regular, mode: .nothing)
        let result = SpaceHubSpacesStorage.filterVisibleDiscussionParents([], spaceView: space)
        #expect(result.isEmpty)
    }

    // MARK: - Fixtures

    private func makeParent(
        id: String,
        unreadMessageCount: Int,
        unreadMentionCount: Int
    ) -> DiscussionUnreadParent {
        DiscussionUnreadParent(
            details: ObjectDetails(id: id, values: [:]),
            lastMessageDate: nil,
            unreadMessageCount: unreadMessageCount,
            unreadMentionCount: unreadMentionCount,
            isSubscribed: true
        )
    }

    private func makeSpace(
        spaceType: SpaceType,
        mode: SpacePushNotificationsMode
    ) -> SpaceView {
        SpaceView(
            id: "space-1",
            name: "Space",
            description: "",
            objectIconImage: .object(.space(.mock)),
            targetSpaceId: "space-1",
            createdDate: nil,
            joinDate: nil,
            accountStatus: .spaceActive,
            localStatus: .ok,
            spaceAccessType: .private,
            readersLimit: nil,
            writersLimit: nil,
            chatId: "",
            spaceOrder: "",
            uxType: spaceType == .oneToOne ? .oneToOne : .data,
            spaceType: spaceType,
            pushNotificationEncryptionKey: "",
            pushNotificationMode: mode,
            forceAllIds: [],
            forceMuteIds: [],
            forceMentionIds: [],
            oneToOneIdentity: "",
            homepage: .empty
        )
    }
}
