import Foundation
import Services
import Combine

enum ChatMessageUpdate: Equatable {
    case message(id: String)
}

protocol ChatMessagesStorageProtocol: AnyObject {
    func getNextTopPage() async throws -> [ChatMessage]
    func getMessages() async -> [ChatMessage]
    func getMessage(id: String) async -> ChatMessage?
    func subscibeFor(update: [ChatMessageUpdate]) async -> AnyPublisher<[ChatMessageUpdate], Never>
}

actor ChatMessagesStorage: ChatMessagesStorageProtocol {
    
    private enum Constants {
        static let pageSize = 15
    }
    
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    
    private var allMessages: [ChatMessage] = []
    private let chatObjectId: String
    
    private let updateSubject = PassthroughSubject<[ChatMessageUpdate], Never>()
    
    init(chatObjectId: String) {
        self.chatObjectId = chatObjectId
    }
    
    func subscibeFor(update: [ChatMessageUpdate]) -> AnyPublisher<[ChatMessageUpdate], Never> {
        return updateSubject
            .merge(with: Just(allMessages.isNotEmpty ? update : []))
            .map { syncUpdate in
                return update.filter { syncUpdate.contains($0) }
            }
            .filter { $0.isNotEmpty }
            .eraseToAnyPublisher()
    }
    
    func getNextTopPage() async throws -> [ChatMessage] {
        let messages = try await chatService.getMessages(
            chatObjectId: chatObjectId,
            beforeMessageId: allMessages.first?.id,
            limit: Constants.pageSize
        )
        allMessages = messages + allMessages
        updateSubject.send(messages.map { ChatMessageUpdate.message(id: $0.id) })
        return messages
    }
    
    func getMessages() -> [ChatMessage] {
        allMessages
    }
    
    func getMessage(id: String) async -> ChatMessage? {
        allMessages.first { $0.id == id }
    }
}
