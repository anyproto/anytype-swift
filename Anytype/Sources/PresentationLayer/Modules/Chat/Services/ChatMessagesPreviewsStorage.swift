import Services
import Foundation
import AnytypeCore
import AsyncTools

protocol ChatMessagesPreviewsStorageProtocol: AnyObject, Sendable {
    func startSubscription() async
    func stopSubscriptionAndClean() async
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
    
    init() {}
    
    var previewsSequence: AnyAsyncSequence<[ChatMessagePreview]> {
        previewsStream.throttle(milliseconds: 300).eraseToAnyAsyncSequence()
    }
    
    var previewsSequenceWithEmpty: AnyAsyncSequence<[ChatMessagePreview]> {
        previewsStream.subscribe([]).throttle(milliseconds: 300).eraseToAnyAsyncSequence()
    }
    
    func previews() -> [ChatMessagePreview] {
        Array(previewsBySpace.values)
    }
    
    // Lifecycle is managed by LoginStateService: started after login, stopped on logout.
    // Without an explicit restart the middleware-side subscription is gone after
    // logout/login and previews stay dead until app restart.
    func startSubscription() async {
        guard subscription == nil else { return }
        guard basicUserInfoStorage.usersId.isNotEmpty else {
            return
        }

        // Register the bus subscription before the RPC so events emitted right after
        // the middleware-side subscription goes live land in the stream buffer.
        let eventStream = await EventBunchSubscribtion.default.stream()
        subscription = Task { [weak self] in
            for await events in eventStream {
                await self?.handle(events: events)
            }
        }

        do {
            let response = try await chatService.subscribeToMessagePreviews(subId: subscriptionId)

            // Stopped while awaiting the response — don't resurrect old previews
            guard subscription != nil else { return }

            for preview in response.previews {
                handleChatState(spaceId: preview.spaceID, chatId: preview.chatObjectID, state: preview.state)
                await handleChatLastMessage(spaceId: preview.spaceID, chatId: preview.chatObjectID, message: preview.message, dependencies: preview.dependencies.compactMap(\.asDetails))
            }

            previewsStream.send(Array(previewsBySpace.values))
        } catch {
            anytypeAssertionFailure("Subscribe to messages previews error", info: ["previewsError": error.localizedDescription])
        }
    }

    func stopSubscriptionAndClean() async {
        subscription?.cancel()
        subscription = nil
        previewsBySpace.removeAll()
        previewsStream.send([])
        guard basicUserInfoStorage.usersId.isNotEmpty else { return }
        try? await chatService.unsubscribeFromMessagePreviews()
    }

    deinit {
        subscription?.cancel()
        subscription = nil
    }

    // MARK: - Private
    
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
            case let .chatDelete(data):
                if handleChatDeleteEvent(spaceId: event.spaceID, contextId: events.contextId, data: data) {
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

    private func handleChatDeleteEvent(spaceId: String, contextId: String, data: ChatDeleteData) -> Bool {
        guard data.subIds.contains(subscriptionId) else { return false }

        let key = ChatMessagePreviewKey(spaceId: spaceId, chatId: contextId)
        guard var preview = previewsBySpace[key] else { return false }

        guard let lastMessage = preview.lastMessage, lastMessage.id == data.id else {
            return false
        }

        preview.lastMessage = nil
        previewsBySpace[key] = preview
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
            id: message.id,
            creator: creator,
            text: messageTextBuilder.makeMessaeWithoutStyle(content: message.message),
            createdAt: message.createdAtDate,
            modifiedAt: message.modifiedAtDate,
            attachments: attachments,
            attachmentCount: attachmentsIds.count,
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
