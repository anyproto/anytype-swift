import Services
import Foundation
import AnytypeCore
import AsyncTools

struct DiscussionMessageCount: Sendable, Hashable {
    let chatId: String
    let count: Int
}

protocol DiscussionMessageCountObserverProtocol: AnyObject, Sendable {
    var messageCountStream: AnyAsyncSequence<DiscussionMessageCount> { get async }
    func startObserving(spaceId: String, chatId: String) async
    func stopObserving() async
}

actor DiscussionMessageCountObserver: DiscussionMessageCountObserverProtocol {

    private let chatService: any ChatServiceProtocol = Container.shared.chatService()
    private let events: EventBunchSubscribtion = .default

    private var currentChatId: String?
    private var currentSpaceId: String?
    private var currentSubId: String?
    private var eventTask: Task<Void, Never>?

    private let stream = AsyncToManyStream<DiscussionMessageCount>()

    var messageCountStream: AnyAsyncSequence<DiscussionMessageCount> {
        stream.eraseToAnyAsyncSequence()
    }

    func startObserving(spaceId: String, chatId: String) async {
        if currentChatId == chatId { return }

        await stopObserving()

        let subId = "DiscussionMessageCountObserver-\(UUID().uuidString)"
        currentSpaceId = spaceId
        currentChatId = chatId
        currentSubId = subId

        eventTask = Task { [weak self, events] in
            for await events in await events.stream() {
                await self?.handle(events: events, expectedSubId: subId)
            }
        }

        do {
            let response = try await chatService.subscribeLastMessages(chatObjectId: chatId, subId: subId, limit: 0)
            guard currentSubId == subId else { return }
            stream.send(DiscussionMessageCount(chatId: chatId, count: Int(response.messageCount)))
        } catch {
            anytypeAssertionFailure("DiscussionMessageCountObserver subscribe failed", info: ["error": error.localizedDescription])
        }
    }

    func stopObserving() async {
        eventTask?.cancel()
        eventTask = nil

        let chatId = currentChatId
        let subId = currentSubId
        currentChatId = nil
        currentSpaceId = nil
        currentSubId = nil

        if let chatId, let subId {
            try? await chatService.unsubscribeLastMessages(chatObjectId: chatId, subId: subId)
        }
    }

    deinit {
        eventTask?.cancel()
        stream.finish()
        let chatId = currentChatId
        let subId = currentSubId
        if let chatId, let subId {
            let chatService = self.chatService
            Task { try? await chatService.unsubscribeLastMessages(chatObjectId: chatId, subId: subId) }
        }
    }

    // MARK: - Private

    private func handle(events: EventsBunch, expectedSubId: String) {
        guard currentSubId == expectedSubId, let currentChatId else { return }
        for event in events.middlewareEvents {
            if case let .chatUpdateMessageCount(data) = event.value {
                guard data.subIds.contains(expectedSubId) else { continue }
                stream.send(DiscussionMessageCount(chatId: currentChatId, count: Int(data.messageCount)))
            }
        }
    }
}
