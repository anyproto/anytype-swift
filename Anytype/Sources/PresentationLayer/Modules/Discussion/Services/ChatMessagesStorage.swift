import Foundation
import Services
import Combine
import AnytypeCore

protocol ChatMessagesStorageProtocol: AnyObject {
    func startSubscription() async throws
    func stopSubscription() async throws
    func loadNextPage() async throws
    var messagesPublisher: AnyPublisher<[ChatMessage], Never> { get async }
}

actor ChatMessagesStorage: ChatMessagesStorageProtocol {
    
    private enum Constants {
        static let pageSize = 10
    }
    
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    private let chatObjectId: String
    
    private var subscriptionStarted = false
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
        let messages = try await chatService.subscribeLastMessages(chatObjectId: chatObjectId, limit: Constants.pageSize)
        subscriptionStarted = true
        allMessages = messages.sorted(by: { $0.orderID < $1.orderID })
    }
    
    func loadNextPage() async throws {
        guard let allMessages, let last = allMessages.first else {
            anytypeAssertionFailure("Last message not found")
            return
        }
        let messages = try await chatService.getMessages(chatObjectId: chatObjectId, beforeOrderId: last.orderID, limit: Constants.pageSize)
        self.allMessages = (allMessages + messages).sorted(by: { $0.orderID < $1.orderID }).uniqued()
    }
    
    deinit {
        Task { [chatService, chatObjectId] in
            try await chatService.unsubscribeLastMessages(chatObjectId: chatObjectId)
        }
    }
    
    func stopSubscription() async throws {
        try await chatService.unsubscribeLastMessages(chatObjectId: chatObjectId)
    }
}
