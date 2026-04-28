import Testing
import Foundation
@testable import Anytype
import Services

struct SpacePreviewCountersBuilderTests {

    // MARK: - Chat-only paths (regression of pre-discussion behavior)

    @Test func multichatAllMode_unreadAndMentionsHighlighted() {
        let space = makeSpace(spaceType: .regular, mode: .all)
        let preview = makePreview(chatId: "c1", unread: 3, mentions: 2)

        let result = SpacePreviewCountersBuilder.build(
            spaceView: space,
            previews: [preview],
            discussionUnread: nil
        )

        #expect(result.totalUnread == 3)
        #expect(result.totalMentions == 2)
        #expect(result.unreadStyle == .highlighted)
        #expect(result.mentionStyle == .highlighted)
    }

    @Test func multichatMentionsMode_unreadMutedMentionsHighlighted() {
        let space = makeSpace(spaceType: .regular, mode: .mentions)
        let preview = makePreview(chatId: "c1", unread: 5, mentions: 1)

        let result = SpacePreviewCountersBuilder.build(
            spaceView: space,
            previews: [preview],
            discussionUnread: nil
        )

        #expect(result.totalUnread == 5)
        #expect(result.totalMentions == 1)
        #expect(result.unreadStyle == .muted)
        #expect(result.mentionStyle == .highlighted)
    }

    @Test func multichatMutedMode_hidesUnreadKeepsMentions() {
        // muteAndHide flag defaults to true; muted multichat: unread is hidden, mention still counts.
        let space = makeSpace(spaceType: .regular, mode: .nothing)
        let preview = makePreview(chatId: "c1", unread: 4, mentions: 1)

        let result = SpacePreviewCountersBuilder.build(
            spaceView: space,
            previews: [preview],
            discussionUnread: nil
        )

        #expect(result.totalUnread == 0)
        #expect(result.totalMentions == 1)
        #expect(result.unreadStyle == .muted)
        #expect(result.mentionStyle == .muted)
    }

    // MARK: - Discussion-only paths

    @Test func discussionOnly_allMode_contributesUnreadAndMentions() {
        let space = makeSpace(spaceType: .regular, mode: .all)
        let unread = makeDiscussionInfo(messages: 4, mentions: 1)

        let result = SpacePreviewCountersBuilder.build(
            spaceView: space,
            previews: [],
            discussionUnread: unread
        )

        #expect(result.totalUnread == 4)
        #expect(result.totalMentions == 1)
    }

    @Test func discussionOnly_mutedMode_hidesUnreadKeepsMentions() {
        let space = makeSpace(spaceType: .regular, mode: .nothing)
        let unread = makeDiscussionInfo(messages: 9, mentions: 2)

        let result = SpacePreviewCountersBuilder.build(
            spaceView: space,
            previews: [],
            discussionUnread: unread
        )

        #expect(result.totalUnread == 0)
        #expect(result.totalMentions == 2)
    }

    // MARK: - Combined chat + discussion

    @Test func combinedChatAndDiscussion_unreadAndMentionsSum() {
        let space = makeSpace(spaceType: .regular, mode: .all)
        let preview = makePreview(chatId: "c1", unread: 2, mentions: 1)
        let unread = makeDiscussionInfo(messages: 3, mentions: 4)

        let result = SpacePreviewCountersBuilder.build(
            spaceView: space,
            previews: [preview],
            discussionUnread: unread
        )

        #expect(result.totalUnread == 5)
        #expect(result.totalMentions == 5)
    }

    // MARK: - One-to-one drops mentions

    @Test func oneToOne_dropsMentionsFromChat() {
        let space = makeSpace(spaceType: .oneToOne, mode: .all)
        let preview = makePreview(chatId: "c1", unread: 2, mentions: 3)

        let result = SpacePreviewCountersBuilder.build(
            spaceView: space,
            previews: [preview],
            discussionUnread: nil
        )

        #expect(result.totalUnread == 2)
        #expect(result.totalMentions == 0)
    }

    @Test func oneToOne_mutedDoesNotHideUnread() {
        // muteAndHide path requires !isOneToOne — so 1:1 muted still keeps unread.
        let space = makeSpace(spaceType: .oneToOne, mode: .nothing)
        let preview = makePreview(chatId: "c1", unread: 7, mentions: 0)

        let result = SpacePreviewCountersBuilder.build(
            spaceView: space,
            previews: [preview],
            discussionUnread: nil
        )

        #expect(result.totalUnread == 7)
    }

    // MARK: - Reactions

    @Test func unreadReactions_inAllMode_highlighted() {
        let space = makeSpace(spaceType: .regular, mode: .all)
        let preview = makePreview(chatId: "c1", unread: 0, mentions: 0, hasReactions: true)

        let result = SpacePreviewCountersBuilder.build(
            spaceView: space,
            previews: [preview],
            discussionUnread: nil
        )

        #expect(result.hasUnreadReactions == true)
        #expect(result.reactionStyle == .highlighted)
    }

    @Test func unreadReactions_inMentionsMode_muted() {
        let space = makeSpace(spaceType: .regular, mode: .mentions)
        let preview = makePreview(chatId: "c1", unread: 0, mentions: 0, hasReactions: true)

        let result = SpacePreviewCountersBuilder.build(
            spaceView: space,
            previews: [preview],
            discussionUnread: nil
        )

        #expect(result.hasUnreadReactions == true)
        #expect(result.reactionStyle == .muted)
    }

    // MARK: - Force overrides

    @Test func forceMute_chatHidesUnreadOnSpaceWithModeAll() {
        let space = makeSpace(
            spaceType: .regular,
            mode: .all,
            forceMuteIds: ["c1"]
        )
        let preview = makePreview(chatId: "c1", unread: 6, mentions: 2)

        let result = SpacePreviewCountersBuilder.build(
            spaceView: space,
            previews: [preview],
            discussionUnread: nil
        )

        // Per-chat mute is a custom override -> styles use highlighted-flags from the loop.
        #expect(result.totalUnread == 0) // muteAndHide hides muted-chat unread
        #expect(result.totalMentions == 2)
        #expect(result.unreadStyle == .muted)    // no chat contributed a highlighted unread
        #expect(result.mentionStyle == .muted)   // .nothing mode for that chat doesn't highlight mention
    }

    @Test func forceAll_chatInMutedSpace_keepsUnreadHighlighted() {
        let space = makeSpace(
            spaceType: .regular,
            mode: .nothing,
            forceAllIds: ["c1"]
        )
        let preview = makePreview(chatId: "c1", unread: 4, mentions: 1)

        let result = SpacePreviewCountersBuilder.build(
            spaceView: space,
            previews: [preview],
            discussionUnread: nil
        )

        // Per-chat .all override: unread+mention both contribute and become highlighted.
        #expect(result.totalUnread == 4)
        #expect(result.totalMentions == 1)
        #expect(result.unreadStyle == .highlighted)
        #expect(result.mentionStyle == .highlighted)
    }

    // MARK: - Fixtures

    private func makeSpace(
        spaceType: SpaceType,
        mode: SpacePushNotificationsMode,
        forceAllIds: [String] = [],
        forceMuteIds: [String] = [],
        forceMentionIds: [String] = []
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
            forceAllIds: forceAllIds,
            forceMuteIds: forceMuteIds,
            forceMentionIds: forceMentionIds,
            oneToOneIdentity: "",
            homepage: .empty
        )
    }

    private func makeDiscussionInfo(messages: Int, mentions: Int) -> SpaceDiscussionsUnreadInfo {
        // Single subscribed parent yields totals: unreadMessageCount=messages, totalMentionCount=mentions.
        SpaceDiscussionsUnreadInfo(parents: [
            DiscussionUnreadParent(
                details: ObjectDetails(id: "p", values: [:]),
                lastMessageDate: nil,
                unreadMessageCount: messages,
                unreadMentionCount: mentions,
                isSubscribed: true
            )
        ])
    }

    private func makePreview(
        chatId: String,
        unread: Int,
        mentions: Int,
        hasReactions: Bool = false
    ) -> ChatMessagePreview {
        var state = ChatState()
        var messages = ChatState.UnreadState()
        messages.counter = Int32(unread)
        var ments = ChatState.UnreadState()
        ments.counter = Int32(mentions)
        state.messages = messages
        state.mentions = ments
        if hasReactions {
            state.unreadReactionOrderID = "reaction-id"
        }
        var preview = ChatMessagePreview(spaceId: "space-1", chatId: chatId)
        preview.state = state
        return preview
    }
}
