import Foundation
import Services
import Combine
import AnytypeCore
import ProtobufMessages

protocol ChatMessagesStorageProtocol: AnyObject {
    func startSubscription() async throws
    func loadNextPage() async throws
    var messagesPublisher: AnyPublisher<[ChatMessage], Never> { get async }
    func attachments(message: ChatMessage) async -> [MessageAttachmentDetails]
}

actor ChatMessagesStorage: ChatMessagesStorageProtocol {
    
    private enum Constants {
        static let pageSize = 10
    }
    
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    @Injected(\.searchService)
    private var seachService: any SearchServiceProtocol
    private let chatObjectId: String
    
    private var subscriptionStarted = false
    private var subscriptions: [AnyCancellable] = []
    private var attachmentsDetails: [MessageAttachmentDetails] = []
    @Published private var allMessages: [ChatMessage]? = nil
        
    init(chatObjectId: String) {
        self.chatObjectId = chatObjectId
    }
    
    var messagesPublisher: AnyPublisher<[ChatMessage], Never> {
        $allMessages.compactMap { $0 }.eraseToAnyPublisher()
    }
    
    func startSubscription() async throws {
        guard !subscriptionStarted else {
            anytypeAssertionFailure("Subscription started")
            return
        }
        
        EventBunchSubscribtion.default.addHandler { [weak self] events in
            guard events.contextId == self?.chatObjectId else { return }
            await self?.handle(events: events)
        }.store(in: &subscriptions)
        
        let messages = try await chatService.subscribeLastMessages(chatObjectId: chatObjectId, limit: Constants.pageSize)
        await loadAttachments(messages: messages)
        subscriptionStarted = true
        allMessages = messages.sorted(by: { $0.orderID < $1.orderID })
    }
    
    func loadNextPage() async throws {
        guard let allMessages, let last = allMessages.first else {
            anytypeAssertionFailure("Last message not found")
            return
        }
        let messages = try await chatService.getMessages(chatObjectId: chatObjectId, beforeOrderId: last.orderID, limit: Constants.pageSize)
        await loadAttachments(messages: messages)
        self.allMessages = (allMessages + messages).sorted(by: { $0.orderID < $1.orderID }).uniqued()
    }
    
    func attachments(message: ChatMessage) async -> [MessageAttachmentDetails] {
        let ids = message.attachments.map(\.target)
        return attachmentsDetails.filter { ids.contains($0.id) }
    }
    
    deinit {
        Task { [chatService, chatObjectId] in
            try await chatService.unsubscribeLastMessages(chatObjectId: chatObjectId)
        }
    }
    
    // MARK: - Private
    
    private func handle(events: EventsBunch) async {
        for event in events.middlewareEvents {
            switch event.value {
            case let .chatAdd(data):
                allMessages = ((allMessages ?? []) + [data.message]).sorted(by: { $0.orderID < $1.orderID }).uniqued()
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
        let loadedAttachmentsIds = attachmentsDetails.map(\.id)
        let attachmentsInMessage = messages.flatMap { $0.attachments.map(\.target) }
        let newAttachmentsIds = attachmentsInMessage.filter { !loadedAttachmentsIds.contains($0) }
        if let newAttachmentsDetails = try? await seachService.searchObjects(objectIds: newAttachmentsIds) {
            let newAttachments = newAttachmentsDetails.map { MessageAttachmentDetails(details: $0) }
            attachmentsDetails.append(contentsOf: newAttachments)
        }
    }
}

extension Container {
    var chatMessageStorage: ParameterFactory<String, any ChatMessagesStorageProtocol> {
        self { ChatMessagesStorage(chatObjectId: $0) }
    }
}
