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
        currentChatId = chatId
        currentSubId = subId

        eventTask = Task { [weak self, events] in
            for await events in await events.stream() {
                await self?.handle(events: events, expectedSubId: subId)
            }
        }

        do {
            let response = try await chatService.subscribeLastMessages(chatObjectId: chatId, subId: subId, limit: 0)
            // Superseded while the RPC was in flight — unsubscribe to avoid a server-side
            // orphan, don't emit (a newer attempt is already active on this actor).
            guard currentSubId == subId else {
                try? await chatService.unsubscribeLastMessages(chatObjectId: chatId, subId: subId)
                return
            }
            stream.send(DiscussionMessageCount(chatId: chatId, count: Int(response.messageCount)))
        } catch {
            // Only clear state if we're still the active attempt; otherwise a later
            // startObserving has taken over and must not be clobbered.
            guard currentSubId == subId else { return }
            eventTask?.cancel()
            eventTask = nil
            currentChatId = nil
            currentSubId = nil
        }
    }

    func stopObserving() async {
        eventTask?.cancel()
        eventTask = nil

        let chatId = currentChatId
        let subId = currentSubId
        currentChatId = nil
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
