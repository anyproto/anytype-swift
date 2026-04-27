import Testing
import Foundation
@testable import Anytype
import Services
import SwiftProtobuf

struct BadgeTotalCalculatorTests {

    private let spaceA = "space-a"
    private let spaceB = "space-b"
    private let chat1 = "chat-1"
    private let chat2 = "chat-2"

    // MARK: - Sanity

    @Test func emptyInputs_totalIsZero() {
        let total = BadgeTotalCalculator.compute(
            previews: [],
            spaceViews: [],
            chatDetails: [],
            discussionsBySpace: [:]
        )
        #expect(total == 0)
    }

    // MARK: - Discussion contribution by mode

    @Test func discussion_allMode_addsUnreadMessageCount() {
        let info = makeDiscussionInfo(messages: 4, subscribedMentions: 1, unsubscribedMentions: 0)
        let total = BadgeTotalCalculator.compute(
            previews: [],
            spaceViews: [makeSpaceView(spaceId: spaceA, pushMode: .all)],
            chatDetails: [],
            discussionsBySpace: [spaceA: info]
        )
        // unreadMessageCount already includes subscribed mentions; do not double-count.
        #expect(total == 4)
    }

    @Test func discussion_allMode_addsUnsubscribedMentionsOnTop() {
        let info = makeDiscussionInfo(messages: 4, subscribedMentions: 1, unsubscribedMentions: 2)
        let total = BadgeTotalCalculator.compute(
            previews: [],
            spaceViews: [makeSpaceView(spaceId: spaceA, pushMode: .all)],
            chatDetails: [],
            discussionsBySpace: [spaceA: info]
        )
        #expect(total == 6) // 4 subscribed + 2 unsubscribed mentions
    }

    @Test func discussion_allMode_unsubscribedMentionOnly() {
        let info = makeDiscussionInfo(messages: 0, subscribedMentions: 0, unsubscribedMentions: 3)
        let total = BadgeTotalCalculator.compute(
            previews: [],
            spaceViews: [makeSpaceView(spaceId: spaceA, pushMode: .all)],
            chatDetails: [],
            discussionsBySpace: [spaceA: info]
        )
        #expect(total == 3)
    }

    @Test func discussion_mentionsMode_addsTotalMentions() {
        let info = makeDiscussionInfo(messages: 8, subscribedMentions: 2, unsubscribedMentions: 1)
        let total = BadgeTotalCalculator.compute(
            previews: [],
            spaceViews: [makeSpaceView(spaceId: spaceA, pushMode: .mentions)],
            chatDetails: [],
            discussionsBySpace: [spaceA: info]
        )
        #expect(total == 3) // subscribed mentions (2) + unsubscribed mentions (1)
    }

    @Test func discussion_nothingMode_skipped() {
        let info = makeDiscussionInfo(messages: 9, subscribedMentions: 4, unsubscribedMentions: 5)
        let total = BadgeTotalCalculator.compute(
            previews: [],
            spaceViews: [makeSpaceView(spaceId: spaceA, pushMode: .nothing)],
            chatDetails: [],
            discussionsBySpace: [spaceA: info]
        )
        #expect(total == 0)
    }

    @Test func discussion_oneToOneSpace_mentionsModeNotApplied() {
        // 1:1 spaces don't support mentions; .mentions mode contributes 0.
        let info = makeDiscussionInfo(messages: 5, subscribedMentions: 1, unsubscribedMentions: 1)
        let total = BadgeTotalCalculator.compute(
            previews: [],
            spaceViews: [makeSpaceView(spaceId: spaceA, uxType: .oneToOne, spaceType: .oneToOne, pushMode: .mentions)],
            chatDetails: [],
            discussionsBySpace: [spaceA: info]
        )
        #expect(total == 0)
    }

    // MARK: - Chat contribution preserved

    @Test func chat_allMode_addsUnreadCounter() {
        let preview = makeChatPreview(spaceId: spaceA, chatId: chat1, unread: 3, mentions: 1)
        let total = BadgeTotalCalculator.compute(
            previews: [preview],
            spaceViews: [makeSpaceView(spaceId: spaceA, pushMode: .all)],
            chatDetails: [makeChatDetail(id: chat1)],
            discussionsBySpace: [:]
        )
        #expect(total == 3)
    }

    @Test func chat_mentionsMode_addsMentionCounterOnly() {
        let preview = makeChatPreview(spaceId: spaceA, chatId: chat1, unread: 5, mentions: 2)
        let total = BadgeTotalCalculator.compute(
            previews: [preview],
            spaceViews: [makeSpaceView(spaceId: spaceA, pushMode: .mentions)],
            chatDetails: [makeChatDetail(id: chat1)],
            discussionsBySpace: [:]
        )
        #expect(total == 2)
    }

    @Test func chat_archivedDetail_skipped() {
        let preview = makeChatPreview(spaceId: spaceA, chatId: chat1, unread: 7, mentions: 0)
        let total = BadgeTotalCalculator.compute(
            previews: [preview],
            spaceViews: [makeSpaceView(spaceId: spaceA, pushMode: .all)],
            chatDetails: [makeChatDetail(id: chat1, isArchived: true)],
            discussionsBySpace: [:]
        )
        #expect(total == 0)
    }

    @Test func chat_forceMutedChannel_skipped() {
        // Per-channel override sets one chat to .nothing inside an .all space.
        let muted = makeChatPreview(spaceId: spaceA, chatId: chat1, unread: 4, mentions: 0)
        let normal = makeChatPreview(spaceId: spaceA, chatId: chat2, unread: 2, mentions: 0)
        let space = makeSpaceView(spaceId: spaceA, pushMode: .all, forceMuteIds: [chat1])
        let total = BadgeTotalCalculator.compute(
            previews: [muted, normal],
            spaceViews: [space],
            chatDetails: [makeChatDetail(id: chat1), makeChatDetail(id: chat2)],
            discussionsBySpace: [:]
        )
        #expect(total == 2)
    }

    // MARK: - Discussion bypasses chat-level overrides

    @Test func discussion_ignoresForceMuteIds() {
        // forceMuteIds is keyed by chatId — discussions live on parent objectIds, so the override
        // does not apply to them. Discussion still contributes to an .all space.
        let info = makeDiscussionInfo(messages: 5, subscribedMentions: 0, unsubscribedMentions: 0)
        let space = makeSpaceView(spaceId: spaceA, pushMode: .all, forceMuteIds: [chat1, "any-parent-id"])
        let total = BadgeTotalCalculator.compute(
            previews: [],
            spaceViews: [space],
            chatDetails: [],
            discussionsBySpace: [spaceA: info]
        )
        #expect(total == 5)
    }

    // MARK: - Active-space filter

    @Test func discussion_inactiveSpace_skipped() {
        let info = makeDiscussionInfo(messages: 7, subscribedMentions: 0, unsubscribedMentions: 0)
        let total = BadgeTotalCalculator.compute(
            previews: [],
            spaceViews: [makeSpaceView(spaceId: spaceA, isActive: false, pushMode: .all)],
            chatDetails: [],
            discussionsBySpace: [spaceA: info]
        )
        #expect(total == 0)
    }

    @Test func discussion_missingSpaceView_skipped() {
        let info = makeDiscussionInfo(messages: 7, subscribedMentions: 0, unsubscribedMentions: 0)
        let total = BadgeTotalCalculator.compute(
            previews: [],
            spaceViews: [], // no space view for spaceA
            chatDetails: [],
            discussionsBySpace: [spaceA: info]
        )
        #expect(total == 0)
    }

    // MARK: - Mixed sources

    @Test func mixed_chatPlusDiscussion_inSameSpace_sums() {
        let preview = makeChatPreview(spaceId: spaceA, chatId: chat1, unread: 4, mentions: 0)
        let info = makeDiscussionInfo(messages: 3, subscribedMentions: 0, unsubscribedMentions: 1)
        let total = BadgeTotalCalculator.compute(
            previews: [preview],
            spaceViews: [makeSpaceView(spaceId: spaceA, pushMode: .all)],
            chatDetails: [makeChatDetail(id: chat1)],
            discussionsBySpace: [spaceA: info]
        )
        #expect(total == 8) // chat 4 + discussion 3 + unsub mention 1
    }

    @Test func multiSpace_differentModes_sumIndependently() {
        // spaceA: .all  → discussion msg 5 + unsub mention 1 = 6
        // spaceB: .mentions → discussion total mentions 2
        let infoA = makeDiscussionInfo(messages: 5, subscribedMentions: 0, unsubscribedMentions: 1)
        let infoB = makeDiscussionInfo(messages: 9, subscribedMentions: 1, unsubscribedMentions: 1)

        let total = BadgeTotalCalculator.compute(
            previews: [],
            spaceViews: [
                makeSpaceView(spaceId: spaceA, pushMode: .all),
                makeSpaceView(spaceId: spaceB, pushMode: .mentions)
            ],
            chatDetails: [],
            discussionsBySpace: [spaceA: infoA, spaceB: infoB]
        )
        #expect(total == 8) // 6 + 2
    }

    // MARK: - Mode change

    @Test func modeChange_sameInputs_differentTotals() {
        let info = makeDiscussionInfo(messages: 5, subscribedMentions: 1, unsubscribedMentions: 2)

        let totalAll = BadgeTotalCalculator.compute(
            previews: [],
            spaceViews: [makeSpaceView(spaceId: spaceA, pushMode: .all)],
            chatDetails: [],
            discussionsBySpace: [spaceA: info]
        )
        let totalMentions = BadgeTotalCalculator.compute(
            previews: [],
            spaceViews: [makeSpaceView(spaceId: spaceA, pushMode: .mentions)],
            chatDetails: [],
            discussionsBySpace: [spaceA: info]
        )
        let totalNothing = BadgeTotalCalculator.compute(
            previews: [],
            spaceViews: [makeSpaceView(spaceId: spaceA, pushMode: .nothing)],
            chatDetails: [],
            discussionsBySpace: [spaceA: info]
        )

        #expect(totalAll == 7) // 5 + 2
        #expect(totalMentions == 3) // 1 + 2
        #expect(totalNothing == 0)
    }

    // MARK: - Fixtures

    private func makeSpaceView(
        spaceId: String,
        isActive: Bool = true,
        uxType: SpaceUxType = .data,
        spaceType: SpaceType = .regular,
        pushMode: SpacePushNotificationsMode = .all,
        forceAllIds: [String] = [],
        forceMuteIds: [String] = [],
        forceMentionIds: [String] = []
    ) -> SpaceView {
        SpaceView(
            id: "view-\(spaceId)",
            name: "",
            description: "",
            objectIconImage: .object(.space(.name(name: "", iconOption: 0, circular: false))),
            targetSpaceId: spaceId,
            createdDate: nil,
            joinDate: nil,
            accountStatus: .spaceActive,
            localStatus: isActive ? .ok : .loading,
            spaceAccessType: nil,
            readersLimit: nil,
            writersLimit: nil,
            chatId: "",
            spaceOrder: "",
            uxType: uxType,
            spaceType: spaceType,
            pushNotificationEncryptionKey: "",
            pushNotificationMode: pushMode,
            forceAllIds: forceAllIds,
            forceMuteIds: forceMuteIds,
            forceMentionIds: forceMentionIds,
            oneToOneIdentity: "",
            homepage: .empty
        )
    }

    private func makeChatPreview(
        spaceId: String,
        chatId: String,
        unread: Int,
        mentions: Int
    ) -> ChatMessagePreview {
        var preview = ChatMessagePreview(spaceId: spaceId, chatId: chatId)
        var state = ChatState()

        var messagesState = ChatState.UnreadState()
        messagesState.counter = Int32(unread)
        state.messages = messagesState

        var mentionsState = ChatState.UnreadState()
        mentionsState.counter = Int32(mentions)
        state.mentions = mentionsState

        preview.state = state
        return preview
    }

    private func makeChatDetail(id: String, isArchived: Bool = false, isDeleted: Bool = false) -> ObjectDetails {
        var values: [String: Google_Protobuf_Value] = [:]
        if isArchived {
            values[BundledPropertyKey.isArchived.rawValue] = true.protobufValue
        }
        if isDeleted {
            values[BundledPropertyKey.isDeleted.rawValue] = true.protobufValue
        }
        return ObjectDetails(id: id, values: values)
    }

    private func makeDiscussionInfo(
        messages: Int,
        subscribedMentions: Int,
        unsubscribedMentions: Int
    ) -> SpaceDiscussionsUnreadInfo {
        SpaceDiscussionsUnreadInfo(
            unreadMessageCount: messages,
            mentions: SpaceDiscussionsMentions(
                subscribedCount: subscribedMentions,
                unsubscribedCount: unsubscribedMentions
            ),
            parents: []
        )
    }
}
