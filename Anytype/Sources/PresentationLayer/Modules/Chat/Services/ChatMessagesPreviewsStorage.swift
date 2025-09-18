import Services
import Foundation
import AnytypeCore
import AsyncTools

protocol ChatMessagesPreviewsStorageProtocol: AnyObject, Sendable {
    func previews() async -> [ChatMessagePreview]
    var previewsSequence: AnyAsyncSequence<[ChatMessagePreview]> { get async }
    var previewsSequenceWithEmpty: AnyAsyncSequence<[ChatMessagePreview]> { get async }
}

fileprivate struct ChatMessagePreviewKey: Hashable {
    let spaceId: String
    let chatId: String
}

actor ChatMessagesPreviewsStorage: ChatMessagesPreviewsStorageProtocol {

    private let chatService: any ChatServiceProtocol = Container.shared.chatService()
    private let basicUserInfoStorage: any BasicUserInfoStorageProtocol = Container.shared.basicUserInfoStorage()
    private let messageTextBuilder: any MessageTextBuilderProtocol = Container.shared.messageTextBuilder()
    
    // MARK: - Subscriptions State
    
    private let subscriptionId = "ChatMessagesPreviewsStorage-\(UUID().uuidString)"
    private var subscription: Task<Void, Never>?
    
    private var previewsBySpace = [ChatMessagePreviewKey: ChatMessagePreview]()
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
        Task { [chatService, basicUserInfoStorage] in
            guard basicUserInfoStorage.usersId.isNotEmpty else { return }
            try await chatService.unsubscribeFromMessagePreviews()
        }
    }
    
    // MARK: - Private
    
    private func startSubscription() async {
        guard basicUserInfoStorage.usersId.isNotEmpty else {
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
                handleChatState(spaceId: preview.spaceID, chatId: preview.chatObjectID, state: preview.state)
                await handleChatLastMessage(spaceId: preview.spaceID, chatId: preview.chatObjectID, message: preview.message, dependencies: preview.dependencies.compactMap(\.asDetails))
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
        
        handleChatState(spaceId: spaceId, chatId: contextId, state: state.state)
        return true
    }
    
    private func handleChatState(spaceId: String, chatId: String, state: ChatState) {
        let key = ChatMessagePreviewKey(spaceId: spaceId, chatId: chatId)
        var preview = previewsBySpace[key] ?? ChatMessagePreview(spaceId: spaceId, chatId: chatId)
        
        if (preview.state?.order ?? -1) < state.order {
            preview.state = state
        }
        
        self.previewsBySpace[key] = preview
    }
    
    private func handleChatAddEvent(spaceId: String, contextId: String, data: ChatAddData) async -> Bool {
        guard data.subIds.contains(subscriptionId) else { return false }
        
        await handleChatLastMessage(spaceId: spaceId, chatId: contextId, message: data.message, dependencies: data.dependencies.compactMap(\.asDetails))
        return true
    }
    
    private func handleChatLastMessage(spaceId: String, chatId: String, message: ChatMessage, dependencies: [ObjectDetails]) async {
        guard message.hasMessage else { return }
      
        let key = ChatMessagePreviewKey(spaceId: spaceId, chatId: chatId)
        var preview = previewsBySpace[key] ?? ChatMessagePreview(spaceId: spaceId, chatId: chatId)
        
        if let lastMessage = preview.lastMessage, lastMessage.orderId > message.orderID {
            return
        }
        
        let attachmentsIds = message.attachments.map(\.target)
        let attachments = attachmentsIds.compactMap { id in dependencies.first { $0.id == id } }
        
        // TODO: change to full equality after MW fix
        let creator = dependencies.first { $0.id.hasSuffix(message.creator) }.flatMap { try? Participant(details: $0) }
        
        let message = LastMessagePreview(
            creator: creator,
            text: messageTextBuilder.makeMessaeWithoutStyle(content: message.message),
            createdAt: message.createdAtDate,
            modifiedAt: message.modifiedAtDate,
            attachments: attachments,
            orderId: message.orderID
        )
        
        preview.lastMessage = message
        
        self.previewsBySpace[key] = preview
    }
}

extension Container {
    var chatMessagesPreviewsStorage: Factory<any ChatMessagesPreviewsStorageProtocol> {
        self { ChatMessagesPreviewsStorage() }.shared
    }
}
