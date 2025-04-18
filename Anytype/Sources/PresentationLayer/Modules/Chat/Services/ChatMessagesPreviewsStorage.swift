import Services
import AnytypeCore
import AsyncTools

protocol ChatMessagesPreviewsStorageProtocol: AnyObject, Sendable {
    func startSubscriptionIfNeeded() async
    func previews() async -> [ChatMessagePreview]
    var previewsSequence: AnyAsyncSequence<[ChatMessagePreview]> { get async }
}

actor ChatMessagesPreviewsStorage: ChatMessagesPreviewsStorageProtocol {

    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    @Injected(\.userDefaultsStorage)
    private var userDefaultsStorage: any UserDefaultsStorageProtocol
    
    // MARK: - Subscriptions State
    
    private var subscriptionId: String? = nil
    private var subscription: Task<Void, Never>?
    
    private var previewsBySpace = [String: ChatMessagePreview]()
    private let previewsStream = AsyncToManyStream<[ChatMessagePreview]>()
    
    var previewsSequence: AnyAsyncSequence<[ChatMessagePreview]> {
        previewsStream._throttle(for: .microseconds(50)).eraseToAnyAsyncSequence()
    }
    
    func startSubscriptionIfNeeded() async {
        guard subscriptionId == nil, userDefaultsStorage.usersId.isNotEmpty else {
            return
        }
        
        subscription = Task { [weak self] in
            for await events in await EventBunchSubscribtion.default.stream() {
                await self?.handle(events: events)
            }
        }
        
        do {
            subscriptionId = try await chatService.subscribeToMessagePreviews()
        } catch {
            anytypeAssertionFailure("Subscribe to messages previews error", info: ["previewsError": error.localizedDescription])
        }
    }
    
    func previews() -> [ChatMessagePreview] {
        Array(previewsBySpace.values)
    }
    
    deinit {
        subscription?.cancel()
        subscription = nil
        // Implemented in swift 6.1 https://github.com/swiftlang/swift-evolution/blob/main/proposals/0371-isolated-synchronous-deinit.md
        Task { [chatService, userDefaultsStorage, subscriptionId] in
            guard userDefaultsStorage.usersId.isNotEmpty else { return }
            if subscriptionId.isNotNil {
                try await chatService.unsubscribeFromMessagePreviews()
            }
        }
    }
    
    // MARK: - Private
    
    private func handle(events: EventsBunch) async {
        var hasChanges = false
        
        for event in events.middlewareEvents {
            switch event.value {
            case let .chatStateUpdate(state):
                if handleChatStateUpdateEvent(event, state: state) {
                    hasChanges = true
                }
            default:
                break
            }
        }
        
        if hasChanges {
            previewsStream.send(Array(previewsBySpace.values))
        }
    }
    
    private func handleChatStateUpdateEvent(_ event: MiddlewareEventMessage, state: ChatUpdateState) -> Bool {
        guard let subscriptionId, state.subIds.contains(subscriptionId) else { return false }
        let preview = ChatMessagePreview(
            spaceId: event.spaceID,
            counter: Int(state.state.messages.counter)
        )
        self.previewsBySpace[event.spaceID] = preview
        return true
    }
}

extension Container {
    var chatMessagesPreviewsStorage: Factory<any ChatMessagesPreviewsStorageProtocol> {
        self { ChatMessagesPreviewsStorage() }
    }
}
