import Testing
import Foundation
@testable import Anytype
import Services

struct SpaceHubSpacesStorageVisibleParentsTests {

    @Test func mutedMultichat_keepsOnlyMentionParents() {
        let space = makeSpace(spaceType: .regular, mode: .nothing)
        let mentionParent = makeParent(id: "p-mention", hasUnreadMention: true)
        let messageOnly = makeParent(id: "p-message", hasUnreadMention: false)

        let result = SpaceHubSpacesStorage.filterVisibleDiscussionParents(
            [mentionParent, messageOnly],
            spaceView: space
        )

        #expect(result.map(\.id) == ["p-mention"])
    }

    @Test func allMode_keepsAllParents() {
        let space = makeSpace(spaceType: .regular, mode: .all)
        let mentionParent = makeParent(id: "p-mention", hasUnreadMention: true)
        let messageOnly = makeParent(id: "p-message", hasUnreadMention: false)

        let result = SpaceHubSpacesStorage.filterVisibleDiscussionParents(
            [mentionParent, messageOnly],
            spaceView: space
        )

        #expect(result.map(\.id) == ["p-mention", "p-message"])
    }

    @Test func mentionsMode_keepsAllParents() {
        let space = makeSpace(spaceType: .regular, mode: .mentions)
        let mentionParent = makeParent(id: "p-mention", hasUnreadMention: true)
        let messageOnly = makeParent(id: "p-message", hasUnreadMention: false)

        let result = SpaceHubSpacesStorage.filterVisibleDiscussionParents(
            [mentionParent, messageOnly],
            spaceView: space
        )

        #expect(result.map(\.id) == ["p-mention", "p-message"])
    }

    @Test func oneToOneMuted_keepsAllParents() {
        // 1:1 spaces are excluded from the muted-hide path.
        let space = makeSpace(spaceType: .oneToOne, mode: .nothing)
        let mentionParent = makeParent(id: "p-mention", hasUnreadMention: true)
        let messageOnly = makeParent(id: "p-message", hasUnreadMention: false)

        let result = SpaceHubSpacesStorage.filterVisibleDiscussionParents(
            [mentionParent, messageOnly],
            spaceView: space
        )

        #expect(result.map(\.id) == ["p-mention", "p-message"])
    }

    @Test func emptyInput_returnsEmpty() {
        let space = makeSpace(spaceType: .regular, mode: .nothing)
        let result = SpaceHubSpacesStorage.filterVisibleDiscussionParents([], spaceView: space)
        #expect(result.isEmpty)
    }

    // MARK: - Fixtures

    private func makeParent(id: String, hasUnreadMention: Bool) -> DiscussionUnreadParent {
        DiscussionUnreadParent(
            id: id,
            name: "Doc \(id)",
            lastMessageDate: nil,
            hasUnreadMention: hasUnreadMention
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
