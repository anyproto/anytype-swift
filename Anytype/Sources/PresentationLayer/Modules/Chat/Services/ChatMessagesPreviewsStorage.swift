import Services
import AnytypeCore
import AsyncTools

protocol ChatMessagesPreviewsStorageProtocol: AnyObject, Sendable {
    func startSubscriptionIfNeeded() async
    func previews() async -> [ChatMessagePreview]
    var previewStream: AnyAsyncSequence<ChatMessagePreview> { get }
}

actor ChatMessagesPreviewsStorage: ChatMessagesPreviewsStorageProtocol {

    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    @Injected(\.userDefaultsStorage)
    private var userDefaultsStorage: any UserDefaultsStorageProtocol
    
    // MARK: - Subscriptions State
    
    private var subscriptionId: String? = nil
    private var subscription: Task<Void, Never>?
    
    private var preview: ChatMessagePreview?
    private var previewsBySpace: [String: ChatMessagePreview] = [:]
    
    private let syncStream = AsyncToManyStream<[ChatMessagePreview]>()
    
    nonisolated var previewStream: AnyAsyncSequence<ChatMessagePreview> {
        AsyncStream.convertData(syncStream) {
            await preview
        }.eraseToAnyAsyncSequence()
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
    
    func previews() async -> [ChatMessagePreview] {
        Array(previewsBySpace.values)
    }
    
    
    deinit {
        subscription?.cancel()
        subscription = nil
        // Implemented in swift 6.1 https://github.com/swiftlang/swift-evolution/blob/main/proposals/0371-isolated-synchronous-deinit.md
        Task { [chatService, userDefaultsStorage] in
            guard userDefaultsStorage.usersId.isNotEmpty else { return }
            try await chatService.unsubscribeFromMessagePreviews()
        }
    }
    
    // MARK: - Private
    
    private func handle(events: EventsBunch) async {
        var updates: Set<ChatMessagePreview> = []
        
        for event in events.middlewareEvents {
            switch event.value {
            case let .chatStateUpdate(state):
                if let preview = handleChatStateUpdateEvent(event, state: state) {
                    updates.insert(preview)
                }
            default:
                break
            }
        }
        
        syncStream.send(Array(updates))
    }
    
    private func handleChatStateUpdateEvent(_ event: MiddlewareEventMessage, state: ChatUpdateState) -> ChatMessagePreview? {
        guard let subscriptionId, state.subIds.contains(subscriptionId) else { return nil }
        let preview = ChatMessagePreview(
            spaceId: event.spaceID,
            counter: Int(state.state.messages.counter)
        )
        self.preview = preview
        self.previewsBySpace[event.spaceID] = preview
        return preview
    }
}

extension Container {
    var chatMessagesPreviewsStorage: Factory<any ChatMessagesPreviewsStorageProtocol> {
        self { ChatMessagesPreviewsStorage() }
    }
}
