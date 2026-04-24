import Testing
import Foundation
@testable import Anytype
import Services
import ProtobufMessages

@Suite(.serialized)
struct DiscussionMessageCountObserverTests {

    private let chatService: ChatServiceMock

    init() {
        let mock = ChatServiceMock()
        Container.shared.chatService.register { mock }
        self.chatService = mock
    }

    @Test func startObserving_subscribesWithChatIdAndLimitZero() async {
        let observer = DiscussionMessageCountObserver()

        await observer.startObserving(chatId: "chat-a")

        #expect(chatService.subscribeLastMessagesCalls.count == 1)
        let call = chatService.subscribeLastMessagesCalls.first
        #expect(call?.chatObjectId == "chat-a")
        #expect(call?.limit == 0)

        await observer.stopObserving()
    }

    @Test func startObserving_emitsInitialCountFromResponse() async {
        chatService.subscribeLastMessagesMessageCount = 7
        let observer = DiscussionMessageCountObserver()

        await observer.startObserving(chatId: "chat-a")

        var iterator = await observer.messageCountStream.makeAsyncIterator()
        let emission = await iterator.next()

        #expect(emission?.chatId == "chat-a")
        #expect(emission?.count == 7)

        await observer.stopObserving()
    }

    @Test func startObserving_sameChatIdTwice_subscribesOnce() async {
        let observer = DiscussionMessageCountObserver()

        await observer.startObserving(chatId: "chat-a")
        await observer.startObserving(chatId: "chat-a")

        #expect(chatService.subscribeLastMessagesCalls.count == 1)
        #expect(chatService.unsubscribeLastMessagesCalls.isEmpty)

        await observer.stopObserving()
    }

    @Test func startObserving_differentChatId_unsubscribesPreviousThenSubscribesNew() async {
        let observer = DiscussionMessageCountObserver()

        await observer.startObserving(chatId: "chat-a")
        let firstSubId = chatService.subscribeLastMessagesCalls.first?.subId

        await observer.startObserving(chatId: "chat-b")

        #expect(chatService.subscribeLastMessagesCalls.count == 2)
        #expect(chatService.subscribeLastMessagesCalls.last?.chatObjectId == "chat-b")
        #expect(chatService.unsubscribeLastMessagesCalls.count == 1)
        #expect(chatService.unsubscribeLastMessagesCalls.first?.chatObjectId == "chat-a")
        #expect(chatService.unsubscribeLastMessagesCalls.first?.subId == firstSubId)

        await observer.stopObserving()
    }

    @Test func stopObserving_callsUnsubscribeWithMatchingSubId() async {
        let observer = DiscussionMessageCountObserver()

        await observer.startObserving(chatId: "chat-a")
        let subId = chatService.subscribeLastMessagesCalls.first?.subId

        await observer.stopObserving()

        #expect(chatService.unsubscribeLastMessagesCalls.count == 1)
        #expect(chatService.unsubscribeLastMessagesCalls.first?.chatObjectId == "chat-a")
        #expect(chatService.unsubscribeLastMessagesCalls.first?.subId == subId)
    }

    @Test func stopObserving_whenNotObserving_noUnsubscribeCall() async {
        let observer = DiscussionMessageCountObserver()

        await observer.stopObserving()

        #expect(chatService.unsubscribeLastMessagesCalls.isEmpty)
    }

    @Test func chatUpdateMessageCount_matchingSubId_emitsNewCount() async {
        chatService.subscribeLastMessagesMessageCount = 5
        let observer = DiscussionMessageCountObserver()

        await observer.startObserving(chatId: "chat-a")
        let subId = chatService.subscribeLastMessagesCalls.first?.subId ?? ""

        var iterator = await observer.messageCountStream.makeAsyncIterator()
        _ = await iterator.next()

        await sendMessageCountEvent(contextId: "chat-a", subIds: [subId], count: 11)

        let emission = await iterator.next()
        #expect(emission?.chatId == "chat-a")
        #expect(emission?.count == 11)

        await observer.stopObserving()
    }

    @Test func chatUpdateMessageCount_nonMatchingSubId_ignored() async {
        chatService.subscribeLastMessagesMessageCount = 5
        let observer = DiscussionMessageCountObserver()

        await observer.startObserving(chatId: "chat-a")
        let subId = chatService.subscribeLastMessagesCalls.first?.subId ?? ""

        var iterator = await observer.messageCountStream.makeAsyncIterator()
        _ = await iterator.next()

        // Stale/foreign event — must be ignored. Then send a real one; the next iterator
        // step must yield the real count, not the ignored one.
        await sendMessageCountEvent(contextId: "chat-a", subIds: ["other-sub"], count: 11)
        await sendMessageCountEvent(contextId: "chat-a", subIds: [subId], count: 22)

        let emission = await iterator.next()
        #expect(emission?.count == 22)

        await observer.stopObserving()
    }

    @Test func duplicateCount_notEmitted() async {
        chatService.subscribeLastMessagesMessageCount = 5
        let observer = DiscussionMessageCountObserver()

        await observer.startObserving(chatId: "chat-a")
        let subId = chatService.subscribeLastMessagesCalls.first?.subId ?? ""

        var iterator = await observer.messageCountStream.makeAsyncIterator()
        _ = await iterator.next()

        await sendMessageCountEvent(contextId: "chat-a", subIds: [subId], count: 5)
        await sendMessageCountEvent(contextId: "chat-a", subIds: [subId], count: 8)

        let emission = await iterator.next()
        #expect(emission?.count == 8)

        await observer.stopObserving()
    }

    @Test func subscribeFailure_clearsStateSoRetryProceeds() async {
        struct Boom: Error {}
        chatService.subscribeLastMessagesError = Boom()

        let observer = DiscussionMessageCountObserver()

        await observer.startObserving(chatId: "chat-a")
        #expect(chatService.subscribeLastMessagesCalls.count == 1)

        chatService.subscribeLastMessagesError = nil
        chatService.subscribeLastMessagesMessageCount = 3
        await observer.startObserving(chatId: "chat-a")

        #expect(chatService.subscribeLastMessagesCalls.count == 2)

        await observer.stopObserving()
    }

    // MARK: - Helpers

    private func sendMessageCountEvent(contextId: String, subIds: [String], count: Int32) async {
        var data = Anytype_Event.Chat.UpdateMessageCount()
        data.messageCount = count
        data.subIds = subIds

        var message = Anytype_Event.Message()
        message.value = .chatUpdateMessageCount(data)

        let bunch = EventsBunch(contextId: contextId, middlewareEvents: [message])
        await bunch.send()
    }
}
