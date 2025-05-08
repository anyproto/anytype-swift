import Services
import Foundation
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
    
    private let subscriptionId = "ChatMessagesPreviewsStorage-\(UUID().uuidString)"
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
        Task { [chatService, userDefaultsStorage] in
            guard userDefaultsStorage.usersId.isNotEmpty else { return }
            try await chatService.unsubscribeFromMessagePreviews()
        }
    }
    
    // MARK: - Private
    
    private func startSubscription() async {
        guard userDefaultsStorage.usersId.isNotEmpty else {
            return
        }
        
        subscription = Task { [weak self] in
            for await events in await EventBunchSubscribtion.default.stream() {
                await self?.handle(events: events)
            }
        }
        
        do {

            let response = try await chatService.subscribeToMessagePreviews(subId: subscriptionId)
            
            for preview in response.previews {
                handleChatState(spaceId: preview.spaceID, contextId: preview.chatObjectID, state: preview.state)
                await handleChatLastMessage(spaceId: preview.spaceID, contextId: preview.chatObjectID, message: preview.message)
            }

            previewsStream.send(Array(previewsBySpace.values))
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
        guard state.subIds.contains(subscriptionId) else { return false }
        
        handleChatState(spaceId: spaceId, contextId: contextId, state: state.state)
        return true
    }
    
    private func handleChatState(spaceId: String, contextId: String, state: ChatState) {
        var preview = previewsBySpace[spaceId] ?? ChatMessagePreview(spaceId: spaceId, chatId: contextId)
        preview.unreadCounter = Int(state.messages.counter)
        preview.mentionCounter = Int(state.mentions.counter)
            
        self.previewsBySpace[spaceId] = preview
    }
    
    private func handleChatAddEvent(spaceId: String, contextId: String, data: ChatAddData) async -> Bool {
        guard data.subIds.contains(subscriptionId) else { return false }
        
        await handleChatLastMessage(spaceId: spaceId, contextId: contextId, message: data.message)
        return true
    }
    
    private func handleChatLastMessage(spaceId: String, contextId: String, message: ChatMessage) async {
        var preview = previewsBySpace[spaceId] ?? ChatMessagePreview(spaceId: spaceId, chatId: contextId)
        
        let attachmentsIds = message.attachments.map(\.target)
        let attachments = (try? await searchService.searchObjects(spaceId: spaceId, objectIds: attachmentsIds)) ?? [ObjectDetails]()
        let creator = try? await participantService.searchParticipant(spaceId: spaceId, identity: message.creator)
        
        let message = LastMessagePreview(
            creator: creator,
            text: message.message.text,
            createdAt: message.createdAtDate,
            modifiedAt: message.modifiedAtDate,
            attachments: attachments
        )
        
        preview.lastMessage = message
        
        self.previewsBySpace[spaceId] = preview
    }
}

extension Container {
    var chatMessagesPreviewsStorage: Factory<any ChatMessagesPreviewsStorageProtocol> {
        self { ChatMessagesPreviewsStorage() }.shared
    }
}
