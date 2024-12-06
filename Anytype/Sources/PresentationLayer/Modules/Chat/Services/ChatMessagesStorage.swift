import Foundation
import Services
import Combine
import AnytypeCore
import ProtobufMessages

protocol ChatMessagesStorageProtocol: AnyObject {
    func startSubscriptionIfNeeded() async throws
    func loadNextPage() async throws
    func loadPagesTo(messageId: String) async throws
    var messagesPublisher: AnyPublisher<[ChatMessage], Never> { get async }
    func attachments(message: ChatMessage) async -> [MessageAttachmentDetails]
    func reply(message: ChatMessage) async -> ChatMessage?
}

actor ChatMessagesStorage: ChatMessagesStorageProtocol {
    
    private enum Constants {
        static let pageSize = 100
    }
    
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    @Injected(\.searchService)
    private var seachService: any SearchServiceProtocol
    private let chatObjectId: String
    private let spaceId: String
    
    private var subscriptionStarted = false
    private var subscriptions: [AnyCancellable] = []
    private var attachmentsDetails: [MessageAttachmentDetails] = []
    @Published private var allMessages: [ChatMessage]? = nil
    private var replies: [ChatMessage] = []
    
    init(spaceId: String, chatObjectId: String) {
        self.spaceId = spaceId
        self.chatObjectId = chatObjectId
    }
    
    var messagesPublisher: AnyPublisher<[ChatMessage], Never> {
        $allMessages.compactMap { $0 }.eraseToAnyPublisher()
    }
    
    func startSubscriptionIfNeeded() async throws {
        guard !subscriptionStarted else {
            return
        }
    
        let messages = try await chatService.subscribeLastMessages(chatObjectId: chatObjectId, limit: Constants.pageSize)
        await loadAttachments(messages: messages)
        await loadReplies(messages: messages)
        subscriptionStarted = true
        allMessages = messages.sorted(by: { $0.orderID > $1.orderID })
        
        EventBunchSubscribtion.default.addHandler { [weak self] events in
            guard events.contextId == self?.chatObjectId else { return }
            await self?.handle(events: events)
        }.store(in: &subscriptions)
    }
    
    func loadNextPage() async throws {
        guard let allMessages, let last = allMessages.last else {
            anytypeAssertionFailure("Last message not found")
            return
        }
        let messages = try await chatService.getMessages(chatObjectId: chatObjectId, beforeOrderId: last.orderID, limit: Constants.pageSize)
        guard messages.isNotEmpty else { return }
        await loadAttachments(messages: messages)
        await loadReplies(messages: messages)
        self.allMessages = (allMessages + messages).sorted(by: { $0.orderID > $1.orderID }).uniqued()
    }
    
    func loadPagesTo(messageId: String) async throws {
        guard let allMessages else {
            anytypeAssertionFailure("Subscription to meesages sould be started")
            return
        }
        guard !allMessages.contains(where: { $0.id == messageId }) else { return }
        
        var lastMessage = allMessages.last
        var allLoadedMessages = [ChatMessage]()
        while let message = lastMessage {
            let loadedMessages = try await chatService.getMessages(chatObjectId: chatObjectId, beforeOrderId: message.orderID, limit: 2)
            let sortedMessages = loadedMessages.sorted(by: { $0.orderID > $1.orderID })
            allLoadedMessages.append(contentsOf: sortedMessages)
            
            if sortedMessages.contains(where: { $0.id == messageId }) {
                break
            }
            lastMessage = sortedMessages.first
        }
        await loadAttachments(messages: allLoadedMessages)
        await loadReplies(messages: allLoadedMessages)
        self.allMessages = (allMessages + allLoadedMessages).sorted(by: { $0.orderID > $1.orderID }).uniqued()
    }
    
    func attachments(message: ChatMessage) async -> [MessageAttachmentDetails] {
        let ids = message.attachments.map(\.target)
        return attachmentsDetails.filter { ids.contains($0.id) }
    }
    
    func reply(message: ChatMessage) async -> ChatMessage? {
        guard message.replyToMessageID.isNotEmpty else { return nil }
        if let reply = allMessages?.first(where: { $0.id == message.replyToMessageID }) {
            return reply
        }
        return replies.first { $0.id == message.replyToMessageID }
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
                let newAllMessage = ((allMessages ?? []) + [data.message]).sorted(by: { $0.orderID > $1.orderID }).uniqued()
                await loadAttachments(messages: [data.message])
                allMessages = newAllMessage
            case let .chatDelete(data):
                allMessages?.removeAll { $0.id == data.id }
            case let .chatUpdate(data):
                if let index = allMessages?.firstIndex(where: { $0.id == data.id }) {
                    allMessages?[index] = data.message
                }
            case let .chatUpdateReactions(data):
                if let index = allMessages?.firstIndex(where: { $0.id == data.id }) {
                    allMessages?[index].reactions = data.reactions
                }
            default:
                break
            }
        }
    }
    
    private func loadAttachments(messages: [ChatMessage]) async {
        let loadedAttachmentsIds = Set(attachmentsDetails.map(\.id))
        let attachmentsInMessage = Set(messages.flatMap { $0.attachments.map(\.target) })
        let newAttachmentsIds = attachmentsInMessage.subtracting(loadedAttachmentsIds)
        if let newAttachmentsDetails = try? await seachService.searchObjects(spaceId: spaceId, objectIds: Array(newAttachmentsIds)) {
            let newAttachments = newAttachmentsDetails.map { MessageAttachmentDetails(details: $0) }
            attachmentsDetails.append(contentsOf: newAttachments)
        }
    }
    
    private func loadReplies(messages: [ChatMessage]) async {
        let loadedIds = Set(messages.map(\.id) + replies.map(\.id) + (allMessages ?? []).map(\.id))
        let repliesIds = Set(messages.map(\.replyToMessageID))
        let notLoadedIds = repliesIds.subtracting(loadedIds)
        guard notLoadedIds.isNotEmpty else { return }
        do {
            let newReplies = try await chatService.getMessagesByIds(chatObjectId: chatObjectId, messageIds: Array(notLoadedIds))
            replies.append(contentsOf: newReplies)
            await loadAttachments(messages: newReplies)
        } catch {}
    }
}

extension Container {
    var chatMessageStorage: ParameterFactory<(String, String), any ChatMessagesStorageProtocol> {
        self { ChatMessagesStorage(spaceId: $0, chatObjectId: $1) }
    }
}
