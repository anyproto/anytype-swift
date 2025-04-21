import Foundation
import OrderedCollections
import Services
import AnytypeCore
import ProtobufMessages
import AsyncTools

protocol ChatMessagesStorageProtocol: AnyObject, Sendable {
    func startSubscriptionIfNeeded() async throws
    func loadNextPage() async throws
    func loadPrevPage() async throws
    func loadPagesTo(messageId: String) async throws
    func loadPagesTo(orderId: String) async throws -> ChatMessage
    func attachments(message: ChatMessage) async -> [ObjectDetails]
    func attachments(ids: [String]) async -> [ObjectDetails]
    func reply(message: ChatMessage) async -> ChatMessage?
    func message(id: String) async -> ChatMessage?
    func updateVisibleRange(startMessageId: String, endMessageId: String) async
    func markAsReadAll() async throws -> ChatMessage
    var messagesStream: AnyAsyncSequence<[FullChatMessage]> { get }
    var chatStateStream: AnyAsyncSequence<ChatState> { get }
}

actor ChatMessagesStorage: ChatMessagesStorageProtocol {
    
    private enum Constants {
        static let pageSize = 100
        static let maxCacheSize = 1000
        static let lastMessagesMaxCacheSize = 10
        // As user scroll N messages, we update the attachments subscription. Not every message.
        static let subscriptionMessageIntervalForAttachments = 20
        // Subscribe to visible cells attachments AND N top and N bottom. Should be more "interval" value for better experience.
        static let subsctiptionMessageOverLimitForAttachments = 30
    }
    
    private let chatService: any ChatServiceProtocol = Container.shared.chatService()
    @Injected(\.searchService)
    private var seachService: any SearchServiceProtocol
    @Injected(\.objectIdsSubscriptionService)
    private var objectIdsSubscriptionService: any ObjectIdsSubscriptionServiceProtocol
    
    private let chatObjectId: String
    private let spaceId: String
    
    // MARK: - Subscriptions State
    
    private let subId = "ChatMessagesStorage-\(UUID().uuidString)"
    private var subscriptionStarted = false
    private var subscription: Task<Void, Never>?
    private var subscriptionStartMessageId: String?
    private var subscriptionEndMessageId: String?
    private var subscribedAttachmentIds = Set<String>()
    
    // MARK: - Message State
    private var attachments = ChatMessageAttachmentsStorage()
    private var messages = ChatInternalMessageStorage()
    // Need the last message to scroll down. Messages may not store the last message.
    private var lastMessages = ChatInternalMessageStorage()
    private var replies = [String: ChatMessage]()
    private var fullMessages: [FullChatMessage]?
    private var chatState: ChatState?
    
    private let syncStream = AsyncToManyStream<[ChatUpdate]>()
    
    init(spaceId: String, chatObjectId: String) {
        self.spaceId = spaceId
        self.chatObjectId = chatObjectId
    }
    
    nonisolated var messagesStream: AnyAsyncSequence<[FullChatMessage]> {
        AsyncStream.convertData(mergeFirstValue(syncStream, [.messages])) {
            await fullMessages
        }.eraseToAnyAsyncSequence()
    }
    
    nonisolated var chatStateStream: AnyAsyncSequence<ChatState> {
        AsyncStream.convertData(mergeFirstValue(syncStream, [.state])) {
            await chatState
        }.eraseToAnyAsyncSequence()
    }
    
    func updateVisibleRange(startMessageId: String, endMessageId: String) async {
        let startMessageIndex = messages.index(messageId: startMessageId) ?? 0
        let endMessageIndex = messages.index(messageId: endMessageId) ?? 0
        
        let notFoundValue = Constants.subscriptionMessageIntervalForAttachments * -100
        let currentStartMessageIndex = subscriptionStartMessageId.map { messages.index(messageId: $0) ?? notFoundValue } ?? notFoundValue
        let currentEndMessageIndex = subscriptionEndMessageId.map { messages.index(messageId: $0) ?? notFoundValue } ?? notFoundValue
        
        try? await markAsRead(startMessageId: startMessageId, endMessageId: endMessageId)
        
        guard abs(startMessageIndex - currentStartMessageIndex) > Constants.subscriptionMessageIntervalForAttachments
                || abs(endMessageIndex - currentEndMessageIndex) > Constants.subscriptionMessageIntervalForAttachments else { return }
        
        subscriptionStartMessageId = startMessageId
        subscriptionEndMessageId = endMessageId
        await updateAttachmentSubscription()
    }
    
    func startSubscriptionIfNeeded() async throws {
        guard !subscriptionStarted else {
            return
        }

        subscription = Task { [weak self] in
            for await events in await EventBunchSubscribtion.default.stream() {
                if events.contextId == self?.chatObjectId {
                    await self?.handle(events: events)
                }
            }
        }
        
        let response = try await chatService.subscribeLastMessages(chatObjectId: chatObjectId, subId: subId, limit: Constants.pageSize)

        // Setup chat state as first
        chatState = response.chatState
        syncStream.send([.state])
        
        lastMessages.add(response.messages)
        
        let unreadOrderId = response.chatState.messages.oldestOrderID
        if unreadOrderId.isNotEmpty {
            // Load messages for unred bounce
            _ = try? await loadPagesTo(orderId: unreadOrderId)
        } else {
            // Apply subscription state
            await addNewMessages(messages: response.messages)
            updateFullMessages()
        }
        
        subscriptionStarted = true
    }
    
    func loadNextPage() async throws {
        guard let first = messages.first else {
            anytypeAssertionFailure("First message not found")
            return
        }
        let newMessages = try await chatService.getMessages(chatObjectId: chatObjectId, beforeOrderId: first.orderID, limit: Constants.pageSize)
        guard newMessages.isNotEmpty else { return }
        await addNewMessages(messages: newMessages)
        messages.cleaLast(maxCache: Constants.maxCacheSize)
        updateFullMessages()
    }
    
    func loadPrevPage() async throws {
        guard let last = messages.last else {
            anytypeAssertionFailure("Last message not found")
            return
        }
        let newMessages = try await chatService.getMessages(chatObjectId: chatObjectId, afterOrderId: last.orderID, limit: Constants.pageSize)
        guard newMessages.isNotEmpty else { return }
        await addNewMessages(messages: newMessages)
        messages.cleanFirst(maxCache: Constants.maxCacheSize)
        updateFullMessages()
    }
    
    func loadPagesTo(messageId: String) async throws {
        guard messages.message(id: messageId).isNil else { return }
        
        let replyMessage = try await chatService.getMessagesByIds(chatObjectId: chatObjectId, messageIds: [messageId]).first
        
        guard let replyMessage else {
            throw CommonError.undefined
        }
        
        let loadedMessagesBefore = try await chatService.getMessages(chatObjectId: chatObjectId, beforeOrderId: replyMessage.orderID, limit: Constants.pageSize)
        let loadedMessagesAfter = try await chatService.getMessages(chatObjectId: chatObjectId, afterOrderId: replyMessage.orderID, limit: Constants.pageSize)
        
        let allLoadedMessages = loadedMessagesBefore + [replyMessage] + loadedMessagesAfter
        messages.removeAll()
        
        await addNewMessages(messages: allLoadedMessages)
        updateFullMessages()
    }
    
    func loadPagesTo(orderId: String) async throws -> ChatMessage {
        if let message = messages.message(orderId: orderId) {
            return message
        }
        
        let loadedMessagesBefore = try await chatService.getMessages(chatObjectId: chatObjectId, beforeOrderId: orderId, limit: Constants.pageSize)
        let loadedMessagesAfter = try await chatService.getMessages(chatObjectId: chatObjectId, afterOrderId: orderId, limit: Constants.pageSize, includeBoundary: true)
        
        let replyMessage = loadedMessagesAfter.first { $0.orderID == orderId }
        
        guard let replyMessage else {
            throw CommonError.undefined
        }
        
        let allLoadedMessages = loadedMessagesBefore + loadedMessagesAfter
        messages.removeAll()
        
        await addNewMessages(messages: allLoadedMessages)
        updateFullMessages()
        return replyMessage
    }
    
    func attachments(message: ChatMessage) async -> [ObjectDetails] {
        let ids = message.attachments.map(\.target)
        return await attachments(ids: ids)
    }
    
    func attachments(ids: [String]) async -> [ObjectDetails] {
        attachments.details(ids: ids)
    }
    
    func reply(message: ChatMessage) async -> ChatMessage? {
        guard message.replyToMessageID.isNotEmpty else { return nil }
        return messages.message(id: message.replyToMessageID) ?? replies[message.replyToMessageID]
    }
    
    func message(id: String) async -> ChatMessage? {
        return messages.message(id: id)
    }
    
    func markAsReadAll() async throws -> ChatMessage {
        guard let chatState, let last = lastMessages.last else { throw CommonError.undefined }
        try await chatService.readMessages(
            chatObjectId: chatObjectId,
            afterOrderId: "",
            beforeOrderId: last.orderID,
            type: .messages,
            lastStateId: chatState.lastStateID
        )
        return last
    }
    
    deinit {
        subscription?.cancel()
        subscription = nil
        // Implemented in swift 6.1 https://github.com/swiftlang/swift-evolution/blob/main/proposals/0371-isolated-synchronous-deinit.md
        Task { [chatService, chatObjectId, subId] in
            try await chatService.unsubscribeLastMessages(chatObjectId: chatObjectId, subId: subId)
        }
    }
    
    // MARK: - Private
    
    private func handle(events: EventsBunch) async {
        var updates: Set<ChatUpdate> = []
        
        var updateRepliesAndAttachments = true
        
        for event in events.middlewareEvents {
            switch event.value {
            case let .chatAdd(data):
                guard data.subIds.contains(subId) else { break }
                if messages.chatAdd(data) {
                    updates.insert(.messages)
                    updateRepliesAndAttachments = true
                }
                lastMessages.chatAdd(data)
            case let .chatDelete(data):
                guard data.subIds.contains(subId) else { break }
                if messages.chatDelete(data) {
                    updates.insert(.messages)
                }
                lastMessages.chatDelete(data)
            case let .chatUpdate(data):
                guard data.subIds.contains(subId) else { break }
                if messages.chatUpdate(data) {
                    updates.insert(.messages)
                    updateRepliesAndAttachments = true
                }
                lastMessages.chatUpdate(data)
            case let .chatUpdateReactions(data):
                guard data.subIds.contains(subId) else { break }
                if messages.chatUpdateReactions(data) {
                    updates.insert(.messages)
                }
            case let .chatUpdateMessageReadStatus(data):
                guard data.subIds.contains(subId) else { break }
                messages.chatUpdateMessageReadStatus(data)
            case let .chatUpdateMentionReadStatus(data):
                guard data.subIds.contains(subId) else { break }
                messages.chatUpdateMentionReadStatus(data)
            case let .chatStateUpdate(data):
                guard data.subIds.contains(subId) else { break }
                chatState = data.state
                updates.insert(.state)
            default:
                break
            }
        }
        
        lastMessages.cleanFirst(maxCache: Constants.lastMessagesMaxCacheSize)
        
        if updateRepliesAndAttachments {
            await loadReplies()
            await loadAttachments()
            await updateAttachmentSubscription()
        }
        
        if updates.contains(.messages) {
            updateFullMessages(notify: false)
        }
        syncStream.send(Array(updates))
    }
    
    private func addNewMessages(messages newMessages: [ChatMessage]) async {
        messages.add(newMessages)
        
        await loadAttachments()
        await updateAttachmentSubscription()
    }
    
    private func loadAttachments() async {
        let loadedAttachmentsIds = Set(attachments.ids)
        
        let attachmentsForVisibleMessages = messages.messages.flatMap { $0.attachments.map(\.target) }
        let attachmentsForReplies = replies.values.flatMap { $0.attachments.map(\.target) }
        let attachmentsInMessage = Set(attachmentsForVisibleMessages + attachmentsForReplies)
        
        let newAttachmentsIds = attachmentsInMessage.subtracting(loadedAttachmentsIds)
        let oldAttachmentsIds = loadedAttachmentsIds.subtracting(attachmentsInMessage)
        
        // Clean Old
        attachments.remove(ids: Array(oldAttachmentsIds))
        
        // Download New
        guard newAttachmentsIds.isNotEmpty else { return }
        do {
            let newAttachmentsDetails = try await seachService.searchObjects(spaceId: spaceId, objectIds: Array(newAttachmentsIds))
            attachments.update(details: newAttachmentsDetails)
        } catch {}
    }
    
    private func loadReplies() async {
        let loadedIds = messages.ids + replies.keys
        let repliesIds = Set(messages.messages.filter { $0.replyToMessageID.isNotEmpty }.map(\.replyToMessageID))
        let newRepliesIds = repliesIds.subtracting(loadedIds)
        let oldRepliesIds = repliesIds.subtracting(replies.keys)
        
        // Clean Old
        for oldId in oldRepliesIds {
            replies.removeValue(forKey: oldId)
        }
        
        // Download New
        guard newRepliesIds.isNotEmpty else { return }
        do {
            let newReplies = try await chatService.getMessagesByIds(chatObjectId: chatObjectId, messageIds: Array(newRepliesIds))
            for reply in newReplies {
                replies[reply.id] = reply
            }
        } catch {}
    }
    
    private func sortChat(_ chat1: ChatMessage, _ chat2: ChatMessage) -> Bool {
        chat1.orderID < chat2.orderID
    }
    
    private func updateFullMessages(notify: Bool = true) {
        let newFullAllMessages = messages.messages.map { message in
            let replyMessage = messages.message(id: message.replyToMessageID) ?? replies[message.replyToMessageID]
            let replyAttachments = replyMessage?.attachments.compactMap { attachments.details(id: $0.target) } ?? []
            return FullChatMessage(
                message: message,
                attachments: message.attachments.compactMap { attachments.details(id: $0.target) },
                reply: replyMessage,
                replyAttachments: replyAttachments
            )
        }
        if fullMessages != newFullAllMessages {
            fullMessages = newFullAllMessages
            if notify {
                syncStream.send([.messages])
            }
        }
    }
    
    private func updateAttachmentSubscription() async {
        guard let subscriptionStartMessageId, let subscriptionEndMessageId,
              let startMessageIndex = messages.index(messageId: subscriptionStartMessageId),
              let endMessageIndex = messages.index(messageId: subscriptionEndMessageId)  else { return }
        
        let startIndex = startMessageIndex - Constants.subsctiptionMessageOverLimitForAttachments
        let endIndex = endMessageIndex + Constants.subsctiptionMessageOverLimitForAttachments
        
        var attachmentIds = Set<String>()
        
        for index in startIndex...endIndex {
            if let message = messages.message(index: index) {
                let ids = message.attachments.map(\.target)
                attachmentIds = attachmentIds.union(ids)
            }
        }
        
        guard subscribedAttachmentIds != attachmentIds else { return }
        subscribedAttachmentIds = attachmentIds
        
        await objectIdsSubscriptionService.startSubscription(
            spaceId: spaceId,
            objectIds: Array(attachmentIds),
            additionalKeys: [.sizeInBytes, .source, .picture]
        ) { [weak self] details in
            await self?.handleAttachmentSubscription(details: details)
        }
    }
    
    private func markAsRead(startMessageId: String, endMessageId: String) async throws {
        guard let chatState,
              let afterOrderId = messages.message(id: startMessageId)?.orderID,
              let beforeOrderId = messages.message(id: endMessageId)?.orderID
              else { return }
        
        if chatState.messages.oldestOrderID.isNotEmpty,
            chatState.messages.oldestOrderID <= beforeOrderId {
            try? await chatService.readMessages(
                chatObjectId: chatObjectId,
                afterOrderId: afterOrderId,
                beforeOrderId: beforeOrderId,
                type: .messages,
                lastStateId: chatState.lastStateID
            )
        }
        
        if chatState.mentions.oldestOrderID.isNotEmpty,
           chatState.mentions.oldestOrderID <= beforeOrderId {
            try? await chatService.readMessages(
                chatObjectId: chatObjectId,
                afterOrderId: afterOrderId,
                beforeOrderId: beforeOrderId,
                type: .mentions,
                lastStateId: chatState.lastStateID
            )
        }
    }
    
    private func handleAttachmentSubscription(details: [ObjectDetails]) async {
        let updated = attachments.update(details: details)
        if updated {
            updateFullMessages()
        }
    }
}

extension Container {
    var chatMessageStorage: ParameterFactory<(String, String), any ChatMessagesStorageProtocol> {
        self { ChatMessagesStorage(spaceId: $0, chatObjectId: $1) }
    }
}
