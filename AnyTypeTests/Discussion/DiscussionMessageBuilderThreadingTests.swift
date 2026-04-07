import Testing
import Foundation
import Services
import ProtobufMessages
import AsyncTools
@testable import Anytype

// MARK: - Thread Grouper Unit Tests

@Suite
struct DiscussionThreadGrouperTests {

    private let grouper = DiscussionThreadGrouper()

    // MARK: - Helpers

    private func makeMessage(
        id: String,
        orderID: String = "",
        replyToMessageID: String = "",
        creator: String = "user1"
    ) -> FullChatMessage {
        var chatMessage = ChatMessage()
        chatMessage.id = id
        chatMessage.orderID = orderID.isEmpty ? id : orderID
        chatMessage.replyToMessageID = replyToMessageID
        chatMessage.creator = creator
        return FullChatMessage(
            message: chatMessage,
            attachments: [],
            reply: nil,
            replyAttachments: []
        )
    }

    // MARK: - Basic Thread Grouping

    @Test
    func basicThreadGrouping_rootWithTwoReplies() {
        let root = makeMessage(id: "root1", orderID: "001")
        let reply1 = makeMessage(id: "r1", orderID: "002", replyToMessageID: "root1")
        let reply2 = makeMessage(id: "r2", orderID: "003", replyToMessageID: "root1")

        let result = grouper.groupMessagesIntoThreads(messages: [root, reply1, reply2])

        #expect(result.roots.count == 1)
        #expect(result.roots[0].message.id == "root1")
        #expect(result.threadReplies["root1"]?.count == 2)
        #expect(result.threadReplies["root1"]?[0].message.id == "r1")
        #expect(result.threadReplies["root1"]?[1].message.id == "r2")
    }

    // MARK: - Reply-to-Reply Chain

    @Test
    func replyToReplyChain_resolvedToRootParent() {
        // A is root, B replies to A, C replies to B → C grouped under A
        let msgA = makeMessage(id: "A", orderID: "001")
        let msgB = makeMessage(id: "B", orderID: "002", replyToMessageID: "A")
        let msgC = makeMessage(id: "C", orderID: "003", replyToMessageID: "B")

        let result = grouper.groupMessagesIntoThreads(messages: [msgA, msgB, msgC])

        #expect(result.roots.count == 1)
        #expect(result.roots[0].message.id == "A")
        #expect(result.threadReplies["A"]?.count == 2)
        #expect(result.threadReplies["A"]?[0].message.id == "B")
        #expect(result.threadReplies["A"]?[1].message.id == "C")
    }

    // MARK: - Orphan Reply Filtering

    @Test
    func orphanReply_parentNotInMessages_isFiltered() {
        let root = makeMessage(id: "root1", orderID: "001")
        let orphan = makeMessage(id: "orphan1", orderID: "002", replyToMessageID: "missingParent")

        let result = grouper.groupMessagesIntoThreads(messages: [root, orphan])

        #expect(result.roots.count == 1)
        #expect(result.roots[0].message.id == "root1")
        #expect(result.threadReplies.isEmpty)
    }

    // MARK: - Cycle Detection

    @Test
    func cycleDetection_mutualReplies_bothOrphaned() {
        // A replies to B, B replies to A → cycle, both treated as orphans
        let msgA = makeMessage(id: "A", orderID: "001", replyToMessageID: "B")
        let msgB = makeMessage(id: "B", orderID: "002", replyToMessageID: "A")

        let result = grouper.groupMessagesIntoThreads(messages: [msgA, msgB])

        // Both are replies but form a cycle, so both are filtered out
        #expect(result.roots.isEmpty)
        #expect(result.threadReplies.isEmpty)
    }

    @Test
    func cycleDetection_selfReferencingMessage_treatedAsOrphan() {
        // A replies to itself → cycle, treated as orphan
        let msgA = makeMessage(id: "A", orderID: "001", replyToMessageID: "A")

        let result = grouper.groupMessagesIntoThreads(messages: [msgA])

        #expect(result.roots.isEmpty)
        #expect(result.threadReplies.isEmpty)
    }

    // MARK: - Duplicate Message IDs

    @Test
    func duplicateMessageIDs_lastOneWins() {
        let msg1 = makeMessage(id: "dup", orderID: "001")
        let msg2 = makeMessage(id: "dup", orderID: "002")

        let result = grouper.groupMessagesIntoThreads(messages: [msg1, msg2])

        // Both have the same id and empty replyToMessageID, so both appear as roots
        // (the lookup uses last-wins, but both iterate as roots since neither is a reply)
        #expect(result.roots.count == 2)
        #expect(result.threadReplies.isEmpty)
    }

    // MARK: - Ordering

    @Test
    func rootMessages_preserveInputOrder() {
        let root1 = makeMessage(id: "root1", orderID: "001")
        let root2 = makeMessage(id: "root2", orderID: "002")
        let root3 = makeMessage(id: "root3", orderID: "003")

        let result = grouper.groupMessagesIntoThreads(messages: [root1, root2, root3])

        #expect(result.roots.count == 3)
        #expect(result.roots[0].message.id == "root1")
        #expect(result.roots[1].message.id == "root2")
        #expect(result.roots[2].message.id == "root3")
    }

    @Test
    func replies_sortedByOrderIDWithinThread() {
        let root = makeMessage(id: "root1", orderID: "001")
        // Insert replies out of order
        let reply3 = makeMessage(id: "r3", orderID: "004", replyToMessageID: "root1")
        let reply1 = makeMessage(id: "r1", orderID: "002", replyToMessageID: "root1")
        let reply2 = makeMessage(id: "r2", orderID: "003", replyToMessageID: "root1")

        let result = grouper.groupMessagesIntoThreads(messages: [root, reply3, reply1, reply2])

        let replies = result.threadReplies["root1"]
        #expect(replies?.count == 3)
        #expect(replies?[0].message.id == "r1")
        #expect(replies?[1].message.id == "r2")
        #expect(replies?[2].message.id == "r3")
    }

    // MARK: - Edge Cases

    @Test
    func emptyMessages() {
        let result = grouper.groupMessagesIntoThreads(messages: [])

        #expect(result.roots.isEmpty)
        #expect(result.threadReplies.isEmpty)
    }

    @Test
    func singleRootMessage() {
        let root = makeMessage(id: "root1", orderID: "001")

        let result = grouper.groupMessagesIntoThreads(messages: [root])

        #expect(result.roots.count == 1)
        #expect(result.roots[0].message.id == "root1")
        #expect(result.threadReplies.isEmpty)
    }

    @Test
    func allRepliesNoRoots_allFilteredAsOrphans() {
        // All messages are replies to non-existent parents
        let reply1 = makeMessage(id: "r1", orderID: "001", replyToMessageID: "missing1")
        let reply2 = makeMessage(id: "r2", orderID: "002", replyToMessageID: "missing2")

        let result = grouper.groupMessagesIntoThreads(messages: [reply1, reply2])

        #expect(result.roots.isEmpty)
        #expect(result.threadReplies.isEmpty)
    }

    @Test
    func multipleThreads_eachGroupedSeparately() {
        let root1 = makeMessage(id: "root1", orderID: "001")
        let root2 = makeMessage(id: "root2", orderID: "002")
        let reply1A = makeMessage(id: "r1a", orderID: "003", replyToMessageID: "root1")
        let reply2A = makeMessage(id: "r2a", orderID: "004", replyToMessageID: "root2")

        let result = grouper.groupMessagesIntoThreads(messages: [root1, root2, reply1A, reply2A])

        #expect(result.roots.count == 2)
        #expect(result.threadReplies["root1"]?.count == 1)
        #expect(result.threadReplies["root1"]?[0].message.id == "r1a")
        #expect(result.threadReplies["root2"]?.count == 1)
        #expect(result.threadReplies["root2"]?[0].message.id == "r2a")
    }

    @Test
    func deepReplyChain_allGroupedUnderRoot() {
        // A → B → C → D (chain depth 3)
        let msgA = makeMessage(id: "A", orderID: "001")
        let msgB = makeMessage(id: "B", orderID: "002", replyToMessageID: "A")
        let msgC = makeMessage(id: "C", orderID: "003", replyToMessageID: "B")
        let msgD = makeMessage(id: "D", orderID: "004", replyToMessageID: "C")

        let result = grouper.groupMessagesIntoThreads(messages: [msgA, msgB, msgC, msgD])

        #expect(result.roots.count == 1)
        #expect(result.roots[0].message.id == "A")
        #expect(result.threadReplies["A"]?.count == 3)
        #expect(result.threadReplies["A"]?[0].message.id == "B")
        #expect(result.threadReplies["A"]?[1].message.id == "C")
        #expect(result.threadReplies["A"]?[2].message.id == "D")
    }
}

// MARK: - Integration Tests for MessageViewData Flags

@Suite(.serialized)
struct DiscussionMessageBuilderThreadingTests {

    private let mockParticipantsStorage: MockParticipantsStorage
    private let mockTextBuilder: MockDiscussionTextBuilder
    private let mockDocumentProvider: MockOpenedDocumentsProvider

    init() {
        let storage = MockParticipantsStorage()
        let textBuilder = MockDiscussionTextBuilder()
        let docProvider = MockOpenedDocumentsProvider()

        Container.shared.participantsStorage.register { storage }
        Container.shared.discussionTextBuilder.register { textBuilder }
        Container.shared.openedDocumentProvider.register { docProvider }

        self.mockParticipantsStorage = storage
        self.mockTextBuilder = textBuilder
        self.mockDocumentProvider = docProvider
    }

    // MARK: - Helpers

    private func makeMessage(
        id: String,
        orderID: String = "",
        replyToMessageID: String = "",
        creator: String = "user1"
    ) -> FullChatMessage {
        var chatMessage = ChatMessage()
        chatMessage.id = id
        chatMessage.orderID = orderID.isEmpty ? id : orderID
        chatMessage.replyToMessageID = replyToMessageID
        chatMessage.creator = creator
        return FullChatMessage(
            message: chatMessage,
            attachments: [],
            reply: replyToMessageID.isEmpty ? nil : makeChatReply(id: replyToMessageID),
            replyAttachments: []
        )
    }

    private func makeChatReply(id: String) -> ChatMessage {
        var reply = ChatMessage()
        reply.id = id
        reply.creator = "user1"
        return reply
    }

    private func makeLimits() -> MockChatMessageLimits {
        MockChatMessageLimits()
    }

    private func extractMessageViewDataItems(
        from sections: [MessageSectionData]
    ) -> [MessageViewData] {
        sections.flatMap(\.items).compactMap { item in
            if case .message(let data) = item { return data }
            return nil
        }
    }

    // MARK: - isReply Flag

    @Test
    func isReplyFlag_trueForReplies_falseForRoots() async {
        let builder = DiscussionMessageBuilder(spaceId: "space1", chatId: "chat1")

        let root = makeMessage(id: "root1", orderID: "001")
        let reply = makeMessage(id: "r1", orderID: "002", replyToMessageID: "root1")

        let sections = await builder.makeMessage(
            messages: [root, reply],
            participants: [],
            limits: makeLimits()
        )

        let items = extractMessageViewDataItems(from: sections)
        #expect(items.count == 2)
        #expect(items[0].isReply == false)
        #expect(items[1].isReply == true)
    }

    // MARK: - showTopDivider

    @Test
    func showTopDivider_falseForReplies_trueForNonFirstRoots() async {
        let builder = DiscussionMessageBuilder(spaceId: "space1", chatId: "chat1")

        let root1 = makeMessage(id: "root1", orderID: "001")
        let reply1 = makeMessage(id: "r1", orderID: "002", replyToMessageID: "root1")
        let root2 = makeMessage(id: "root2", orderID: "003")

        let sections = await builder.makeMessage(
            messages: [root1, reply1, root2],
            participants: [],
            limits: makeLimits()
        )

        let items = extractMessageViewDataItems(from: sections)
        #expect(items.count == 3)
        // First root: showTopDivider = false
        #expect(items[0].showTopDivider == false)
        // Reply: showTopDivider = false
        #expect(items[1].showTopDivider == false)
        // Second root: showTopDivider = true
        #expect(items[2].showTopDivider == true)
    }

    // MARK: - Full flat list ordering with multiple threads

    @Test
    func flatListOrdering_multipleThreads_repliesFollowTheirRoot() async {
        let builder = DiscussionMessageBuilder(spaceId: "space1", chatId: "chat1")

        let root1 = makeMessage(id: "root1", orderID: "001")
        let root2 = makeMessage(id: "root2", orderID: "002")
        let reply1 = makeMessage(id: "r1", orderID: "003", replyToMessageID: "root1")
        let reply2 = makeMessage(id: "r2", orderID: "004", replyToMessageID: "root2")

        let sections = await builder.makeMessage(
            messages: [root1, root2, reply1, reply2],
            participants: [],
            limits: makeLimits()
        )

        let items = extractMessageViewDataItems(from: sections)
        #expect(items.count == 4)
        #expect(items[0].message.id == "root1")
        #expect(items[1].message.id == "r1")
        #expect(items[2].message.id == "root2")
        #expect(items[3].message.id == "r2")
    }

    // MARK: - replyModel nil for replies, reply preserved

    @Test
    func replyModel_nilForReplies_replyPreserved() async {
        let builder = DiscussionMessageBuilder(spaceId: "space1", chatId: "chat1")

        let root = makeMessage(id: "root1", orderID: "001")
        let reply = makeMessage(id: "r1", orderID: "002", replyToMessageID: "root1")

        let sections = await builder.makeMessage(
            messages: [root, reply],
            participants: [],
            limits: makeLimits()
        )

        let items = extractMessageViewDataItems(from: sections)
        #expect(items.count == 2)
        // Reply should have replyModel = nil (no inline bubble)
        #expect(items[1].replyModel == nil)
        // But raw reply ChatMessage should be preserved for actions
        #expect(items[1].reply != nil)
        #expect(items[1].reply?.id == "root1")
    }
}

// MARK: - Test Mocks

private final class MockParticipantsStorage: ParticipantsStorageProtocol, @unchecked Sendable {
    var participants: [Participant] = []
    var participantsSequence: AnyAsyncSequence<[Participant]> {
        AsyncStream<[Participant]> { _ in }.eraseToAnyAsyncSequence()
    }
    func startSubscription() async {}
    func stopSubscription() async {}
}

private final class MockDiscussionTextBuilder: DiscussionTextBuilderProtocol, @unchecked Sendable {
    func makeAttributedString(
        text: String,
        marks: [Anytype_Model_Block.Content.Text.Mark],
        style: Anytype_Model_Block.Content.Text.Style,
        spaceId: String,
        position: MessageHorizontalPosition
    ) -> AttributedString {
        AttributedString(text)
    }
}

private final class MockOpenedDocumentsProvider: OpenedDocumentsProviderProtocol, @unchecked Sendable {
    func document(objectId: String, spaceId: String, mode: DocumentMode) -> any BaseDocumentProtocol {
        MockBaseDocument(objectId: objectId)
    }

    func setDocument(objectId: String, spaceId: String, mode: DocumentMode) -> any SetDocumentProtocol {
        fatalError("Not needed for threading tests")
    }
}

private final class MockChatMessageLimits: ChatMessageLimitsProtocol, @unchecked Sendable {
    var textLimit: Int { 10000 }
    var attachmentsLimit: Int { 10 }
    func textIsLimited(text: NSAttributedString) -> Bool { false }
    func textIsWarinig(text: NSAttributedString) -> Bool { false }
    func canAddReaction(message: ChatMessage, yourProfileIdentity: String) -> Bool { true }
    func canSendMessage() -> Bool { true }
    func markSentMessage() {}
    func countAttachmentsCanBeAdded(current: Int) -> Int { 10 }
    func oneAttachmentCanBeAdded(current: Int) -> Bool { true }
}
