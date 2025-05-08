import Services
import AnytypeCore
import AsyncTools

protocol ChatMessagesPreviewsStorageProtocol: AnyObject, Sendable {
    func previews() async -> [ChatMessagePreview]
    var previewsSequence: AnyAsyncSequence<[ChatMessagePreview]> { get async }
    var previewsSequenceWithEmpty: AnyAsyncSequence<[ChatMessagePreview]> { get async }
}

actor ChatMessagesPreviewsStorage: ChatMessagesPreviewsStorageProtocol {

    private let chatService: any ChatServiceProtocol = Container.shared.chatService()
    private let userDefaultsStorage: any UserDefaultsStorageProtocol = Container.shared.userDefaultsStorage()
    private let searchService: any SearchServiceProtocol = Container.shared.searchService()
    private let participantService: any ParticipantServiceProtocol = Container.shared.participantService()
    
    // MARK: - Subscriptions State
    
    private var subscriptionId: String? = nil
    private var subscription: Task<Void, Never>?
    
    private var previewsBySpace = [String: ChatMessagePreview]()
    private let previewsStream = AsyncToManyStream<[ChatMessagePreview]>()
    
    init() {
        Task { await startSubscription() }
    }
    
    var previewsSequence: AnyAsyncSequence<[ChatMessagePreview]> {
        previewsStream.throttle(milliseconds: 300).eraseToAnyAsyncSequence()
    }
    
    var previewsSequenceWithEmpty: AnyAsyncSequence<[ChatMessagePreview]> {
        previewsStream.subscribe([]).throttle(milliseconds: 300).eraseToAnyAsyncSequence()
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
    
    private func startSubscription() async {
        guard subscriptionId == nil, userDefaultsStorage.usersId.isNotEmpty else {
            return
        }
        
        subscription = Task { [weak self] in
            for await events in await EventBunchSubscribtion.default.stream() {
                await self?.handle(events: events)
            }
        }
        
        do {
            // TODO: Temporary fix for handle events, that middleware sends before the response
            // Waiting change middleware API
            subscriptionId = "lastMessage"
            subscriptionId = try await chatService.subscribeToMessagePreviews()
        } catch {
            anytypeAssertionFailure("Subscribe to messages previews error", info: ["previewsError": error.localizedDescription])
        }
    }
    
    private func handle(events: EventsBunch) async {
        var hasChanges = false
        
        for event in events.middlewareEvents {
            switch event.value {
            case let .chatStateUpdate(state):
                if handleChatStateUpdateEvent(spaceId: event.spaceID, contextId: events.contextId, state: state) {
                    hasChanges = true
                }
            case let .chatAdd(data):
                if await handleChatAddEvent(spaceId: event.spaceID, contextId: events.contextId, data: data) {
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
    
    private func handleChatStateUpdateEvent(spaceId: String, contextId: String, state: ChatUpdateState) -> Bool {
        guard let subscriptionId, state.subIds.contains(subscriptionId) else { return false }
        
        var preview = previewsBySpace[spaceId] ?? ChatMessagePreview(spaceId: spaceId, chatId: contextId)
        preview.unreadCounter = Int(state.state.messages.counter)
        preview.mentionCounter = Int(state.state.mentions.counter)
            
        self.previewsBySpace[spaceId] = preview
        return true
    }
    
    private func handleChatAddEvent(spaceId: String, contextId: String, data: ChatAddData) async -> Bool {
        guard let subscriptionId, data.subIds.contains(subscriptionId) else { return false }
        
        var preview = previewsBySpace[spaceId] ?? ChatMessagePreview(spaceId: spaceId, chatId: contextId)
        
        let attachmentsIds = data.message.attachments.map(\.target)
        let attachments = (try? await searchService.searchObjects(spaceId: spaceId, objectIds: attachmentsIds)) ?? [ObjectDetails]()
        let creator = try? await participantService.searchParticipant(spaceId: spaceId, identity: data.message.creator)
        
        let message = LastMessagePreview(
            creator: creator,
            text: data.message.message.text,
            createdAt: data.message.createdAtDate,
            modifiedAt: data.message.modifiedAtDate,
            attachments: attachments
        )
        
        preview.lastMessage = message
        
        self.previewsBySpace[spaceId] = preview
        return true
    }
}

extension Container {
    var chatMessagesPreviewsStorage: Factory<any ChatMessagesPreviewsStorageProtocol> {
        self { ChatMessagesPreviewsStorage() }.shared
    }
}
