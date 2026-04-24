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
    func startObserving(chatId: String) async
    func stopObserving() async
}

actor DiscussionMessageCountObserver: DiscussionMessageCountObserverProtocol {

    private let chatService: any ChatServiceProtocol = Container.shared.chatService()
    private let events: EventBunchSubscribtion = .default

    private var current: (chatId: String, subId: String)?
    private var eventTask: Task<Void, Never>?
    private var lastEmittedCount: Int?

    private let stream = AsyncToManyStream<DiscussionMessageCount>()

    var messageCountStream: AnyAsyncSequence<DiscussionMessageCount> {
        stream.eraseToAnyAsyncSequence()
    }

    func startObserving(chatId: String) async {
        if current?.chatId == chatId { return }

        await stopObserving()

        let subId = "DiscussionMessageCountObserver-\(UUID().uuidString)"
        current = (chatId: chatId, subId: subId)

        eventTask = Task { [weak self, events] in
            for await events in await events.stream() {
                await self?.handle(events: events, expectedSubId: subId)
            }
        }

        do {
            let response = try await chatService.subscribeLastMessages(chatObjectId: chatId, subId: subId, limit: 0)
            emit(count: Int(response.messageCount), for: chatId)
        } catch {
            // Clear state so a subsequent startObserving(sameChatId) actually retries
            // instead of being short-circuited by the `current?.chatId == chatId` guard.
            eventTask?.cancel()
            eventTask = nil
            current = nil
        }
    }

    func stopObserving() async {
        eventTask?.cancel()
        eventTask = nil
        lastEmittedCount = nil

        guard let current else { return }
        self.current = nil
        try? await chatService.unsubscribeLastMessages(chatObjectId: current.chatId, subId: current.subId)
    }

    deinit {
        eventTask?.cancel()
        stream.finish()
        if let current {
            let chatService = self.chatService
            Task { try? await chatService.unsubscribeLastMessages(chatObjectId: current.chatId, subId: current.subId) }
        }
    }

    // MARK: - Private

    private func handle(events: EventsBunch, expectedSubId: String) {
        guard let current, current.subId == expectedSubId else { return }
        for event in events.middlewareEvents {
            if case let .chatUpdateMessageCount(data) = event.value {
                guard data.subIds.contains(expectedSubId) else { continue }
                emit(count: Int(data.messageCount), for: current.chatId)
            }
        }
    }

    private func emit(count: Int, for chatId: String) {
        guard lastEmittedCount != count else { return }
        lastEmittedCount = count
        stream.send(DiscussionMessageCount(chatId: chatId, count: count))
    }
}

extension Container {
    var discussionMessageCountObserver: Factory<any DiscussionMessageCountObserverProtocol> {
        self { DiscussionMessageCountObserver() }
    }
}
