import Foundation
import OrderedCollections
import Services
@preconcurrency import Combine
import AnytypeCore
import ProtobufMessages

protocol ChatMessagesStorageProtocol: AnyObject, Sendable {
    func startSubscriptionIfNeeded() async throws
    func loadNextPage() async throws
    func loadPrevPage() async throws
    func loadPagesTo(messageId: String) async throws
    func attachments(message: ChatMessage) async -> [ObjectDetails]
    func attachments(ids: [String]) async -> [ObjectDetails]
    func reply(message: ChatMessage) async -> ChatMessage?
    func updateVisibleRange(starMessageId: String, endMessageId: String) async
    var messagesPublisher: AnyPublisher<[FullChatMessage], Never> { get async }
}

actor ChatMessagesStorage: ChatMessagesStorageProtocol {
    
    private enum Constants {
        static let pageSize = 100
        static let maxCacheSize = 1000
        // As user scroll N messages, we update the attachments subscription. Not every message.
        static let subscriptionMessageIntervalForAttachments = 20
        // Subscribe to visible cells attachments AND N top and N bottom. Should be more "interval" value for better experience.
        static let subsctiptionMessageOverLimitForAttachments = 30
    }
    
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    @Injected(\.searchService)
    private var seachService: any SearchServiceProtocol
    @Injected(\.objectIdsSubscriptionService)
    private var objectIdsSubscriptionService: any ObjectIdsSubscriptionServiceProtocol
    
    private let chatObjectId: String
    private let spaceId: String
    
    // MARK: - Subscriptions State
    
    private var subscriptionStarted = false
    private var subscriptions: [AnyCancellable] = []
    private var subscriptionStartMessageId: String?
    private var subscriptionEndMessageId: String?
    private var subscribedAttachmentIds = Set<String>()
    
    // MARK: - Message State
    
    private var attachmentsDetails: [String: ObjectDetails] = [:]
    private var allMessages = OrderedDictionary<String, ChatMessage>()
    private var replies = [String: ChatMessage]()
    @Published
    private var fullAllMessages: [FullChatMessage]?
    
    var messagesPublisher: AnyPublisher<[FullChatMessage], Never> {
        $fullAllMessages.compactMap { $0 }.eraseToAnyPublisher()
    }
    
    init(spaceId: String, chatObjectId: String) {
        self.spaceId = spaceId
        self.chatObjectId = chatObjectId
    }
    
    func updateVisibleRange(starMessageId: String, endMessageId: String) async {
        let startMessageIndex = allMessages.index(forKey: starMessageId) ?? 0
        let endMessageIndex = allMessages.index(forKey: endMessageId) ?? 0
        
        let notFoundValue = Constants.subscriptionMessageIntervalForAttachments * -100
        let currentStartMessageIndex = subscriptionStartMessageId.map { allMessages.index(forKey: $0) ?? notFoundValue } ?? notFoundValue
        let currentEndMessageIndex = subscriptionEndMessageId.map { allMessages.index(forKey: $0) ?? notFoundValue } ?? notFoundValue
        
        guard abs(startMessageIndex - currentStartMessageIndex) > Constants.subscriptionMessageIntervalForAttachments
                || abs(endMessageIndex - currentEndMessageIndex) > Constants.subscriptionMessageIntervalForAttachments else { return }
        
        subscriptionStartMessageId = starMessageId
        subscriptionEndMessageId = endMessageId
        await updateAttachmentSubscription()
    }
    
    func startSubscriptionIfNeeded() async throws {
        guard !subscriptionStarted else {
            return
        }
    
        let messages = try await chatService.subscribeLastMessages(chatObjectId: chatObjectId, limit: Constants.pageSize)
        await addNewMessages(messages: messages)
        
        subscriptionStarted = true
        
        updateFullMessages()
        
        EventBunchSubscribtion.default.addHandler { [weak self] events in
            guard events.contextId == self?.chatObjectId else { return }
            await self?.handle(events: events)
        }.store(in: &subscriptions)
    }
    
    func loadNextPage() async throws {
        guard let first = allMessages.values.first else {
            anytypeAssertionFailure("Last message not found")
            return
        }
        let messages = try await chatService.getMessages(chatObjectId: chatObjectId, beforeOrderId: first.orderID, afterOrderId: nil, limit: Constants.pageSize)
        guard messages.isNotEmpty else { return }
        await addNewMessages(messages: messages)
        if allMessages.count > Constants.maxCacheSize {
            allMessages.removeLast(allMessages.count - Constants.maxCacheSize)
        }
        updateFullMessages()
    }
    
    func loadPrevPage() async throws {
        guard let last = allMessages.values.last else {
            anytypeAssertionFailure("Last message not found")
            return
        }
        let messages = try await chatService.getMessages(chatObjectId: chatObjectId, beforeOrderId: nil, afterOrderId: last.orderID, limit: Constants.pageSize)
        guard messages.isNotEmpty else { return }
        await addNewMessages(messages: messages)
        if allMessages.count > Constants.maxCacheSize {
            allMessages.removeFirst(allMessages.count - Constants.maxCacheSize)
        }
        updateFullMessages()
    }
    
    func loadPagesTo(messageId: String) async throws {
        guard allMessages[messageId].isNil else { return }
        
        let replyMessage = try await chatService.getMessagesByIds(chatObjectId: chatObjectId, messageIds: [messageId]).first
        
        guard let replyMessage else {
            throw CommonError.undefined
        }
        
        let loadedMessagesBefore = try await chatService.getMessages(chatObjectId: chatObjectId, beforeOrderId: replyMessage.orderID, afterOrderId: nil, limit: Constants.pageSize)
        let loadedMessagesAfter = try await chatService.getMessages(chatObjectId: chatObjectId, beforeOrderId: nil, afterOrderId: replyMessage.orderID, limit: Constants.pageSize)
        
        let allLoadedMessages = loadedMessagesBefore + [replyMessage] + loadedMessagesAfter
        allMessages.removeAll()
        
        await addNewMessages(messages: allLoadedMessages)
        updateFullMessages()
    }
    
    func attachments(message: ChatMessage) async -> [ObjectDetails] {
        let ids = message.attachments.map(\.target)
        return await attachments(ids: ids)
    }
    
    func attachments(ids: [String]) async -> [ObjectDetails] {
        attachmentsDetails.filter { ids.contains($0.key) }.map { $0.value }
    }
    
    func reply(message: ChatMessage) async -> ChatMessage? {
        guard message.replyToMessageID.isNotEmpty else { return nil }
        return allMessages[message.replyToMessageID] ?? replies[message.replyToMessageID]
    }
    
    deinit {
        // Implemented in swift 6.1 https://github.com/swiftlang/swift-evolution/blob/main/proposals/0371-isolated-synchronous-deinit.md
        Task { [chatService, chatObjectId] in
            try await chatService.unsubscribeLastMessages(chatObjectId: chatObjectId)
        }
    }
    
    // MARK: - Private
    
    private func handle(events: EventsBunch) async {
        for event in events.middlewareEvents {
            switch event.value {
            case let .chatAdd(data):
                // TODO: Add message only if page is visible. Waiting middleware API updates.
                // Temporary decition

                // Insert if inside in allMessages
                if let firstMessage = allMessages.values.first, let lastMessage = allMessages.values.last,
                   firstMessage.orderID < data.orderID, lastMessage.orderID > data.orderID {
                    await addNewMessages(messages: [data.message])
                    updateFullMessages()
                    break
                }
                
                // If next
                let topMeessag = try? await chatService.getMessages(chatObjectId: chatObjectId, beforeOrderId: data.orderID, afterOrderId: nil, limit: 1).first
                if allMessages.values.last?.id == topMeessag?.id {
                    await addNewMessages(messages: [data.message])
                    updateFullMessages()
                    break
                }
                
                // If prev
                let bottomMessage = try? await chatService.getMessages(chatObjectId: chatObjectId, beforeOrderId: nil, afterOrderId: data.orderID, limit: 1).first
                if allMessages.values.first?.id == bottomMessage?.id {
                    await addNewMessages(messages: [data.message])
                    updateFullMessages()
                    break
                }
                
            case let .chatDelete(data):
                if allMessages[data.id].isNotNil {
                    allMessages.removeAll { $0.key == data.id }
                    updateFullMessages()
                }
            case let .chatUpdate(data):
                if allMessages[data.message.id].isNotNil {
                    allMessages[data.message.id] = data.message
                    await updateAttachmentSubscription()
                    updateFullMessages()
                }
            case let .chatUpdateReactions(data):
                if allMessages[data.id].isNotNil {
                    allMessages[data.id]?.reactions = data.reactions
                    updateFullMessages()
                }
            default:
                break
            }
        }
    }
    
    private func addNewMessages(messages: [ChatMessage]) async {
        let messageDict = messages.reduce(into: [String: ChatMessage](), { $0[$1.id] = $1 })
        allMessages.merge(messageDict, uniquingKeysWith: { $1 })
        allMessages.sort { sortChat($0.value, $1.value) }
        
        let newReplies = await loadReplies(messages: messages)
        await loadAttachments(messages: messages + newReplies)
        await updateAttachmentSubscription()
    }
    
    private func loadAttachments(messages: [ChatMessage]) async {
        let loadedAttachmentsIds = Set(attachmentsDetails.keys)
        let attachmentsInMessage = Set(messages.flatMap { $0.attachments.map(\.target) })
        let newAttachmentsIds = attachmentsInMessage.subtracting(loadedAttachmentsIds)
        guard newAttachmentsIds.isNotEmpty else { return }
        do {
            let newAttachmentsDetails = try await seachService.searchObjects(spaceId: spaceId, objectIds: Array(newAttachmentsIds))
            updateAttachments(details: newAttachmentsDetails)
        } catch {}
    }
    
    private func loadReplies(messages: [ChatMessage]) async -> [ChatMessage] {
        let loadedIds = Set(messages.map(\.id) + replies.keys + allMessages.keys)
        let repliesIds = Set(messages.filter { $0.replyToMessageID.isNotEmpty }.map(\.replyToMessageID))
        let notLoadedIds = repliesIds.subtracting(loadedIds)
        guard notLoadedIds.isNotEmpty else { return [] }
        do {
            let newReplies = try await chatService.getMessagesByIds(chatObjectId: chatObjectId, messageIds: Array(notLoadedIds))
            for reply in newReplies {
                replies[reply.id] = reply
            }
            return newReplies
        } catch {}
        return []
    }
    
    private func sortChat(_ chat1: ChatMessage, _ chat2: ChatMessage) -> Bool {
        chat1.orderID < chat2.orderID
    }
    
    private func updateAttachments(details: [ObjectDetails], notifyChanges: Bool = false) {
        let newAttachments = details
            .reduce(into: [String: ObjectDetails]()) { $0[$1.id] = $1 }
        
        if attachmentsDetails != newAttachments {
            attachmentsDetails.merge(newAttachments, uniquingKeysWith: { $1 })
            
            if notifyChanges {
                updateFullMessages()
            }
        }
    }
    
    private func updateFullMessages() {
        let newFullAllMessages = allMessages.values.map { message in
            let replyMessage = allMessages[message.replyToMessageID] ?? replies[message.replyToMessageID]
            let replyAttachments = replyMessage?.attachments.compactMap { attachmentsDetails[$0.target] } ?? []
            return FullChatMessage(
                message: message,
                attachments: message.attachments.compactMap { attachmentsDetails[$0.target] },
                reply: replyMessage,
                replyAttachments: replyAttachments
            )
        }
        if fullAllMessages != newFullAllMessages {
            fullAllMessages = newFullAllMessages
        }
    }
    
    private func updateAttachmentSubscription() async {
        guard let subscriptionStartMessageId, let subscriptionEndMessageId,
              let startMessageIndex = allMessages.index(forKey: subscriptionStartMessageId),
              let endMessageIndex = allMessages.index(forKey: subscriptionEndMessageId)  else { return }
        
        let startIndex = startMessageIndex - Constants.subsctiptionMessageOverLimitForAttachments
        let endIndex = endMessageIndex + Constants.subsctiptionMessageOverLimitForAttachments
        
        var attachmentIds = Set<String>()
        
        for index in startIndex...endIndex {
            if let message = allMessages.values[safe: index] {
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
            await self?.updateAttachments(details: details, notifyChanges: true)
        }
    }
}

extension Container {
    var chatMessageStorage: ParameterFactory<(String, String), any ChatMessagesStorageProtocol> {
        self { ChatMessagesStorage(spaceId: $0, chatObjectId: $1) }
    }
}
