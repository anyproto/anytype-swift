import Foundation
import ProtobufMessages

public protocol ChatServiceProtocol: AnyObject {
    func getMessages(chatObjectId: String, beforeOrderId: String?, limit: Int?) async throws -> [ChatMessage]
    func addMessage(chatObjectId: String, message: ChatMessage) async throws -> ChatMessage
    func subscribeLastMessages(chatObjectId: String, limit: Int?) async throws -> [ChatMessage]
    func unsubscribeLastMessages(chatObjectId: String) async throws
}

final class ChatService: ChatServiceProtocol {
    func getMessages(chatObjectId: String, beforeOrderId: String?, limit: Int?) async throws -> [ChatMessage] {
        let result = try await ClientCommands.chatGetMessages(.with {
            $0.chatObjectID = chatObjectId
            $0.beforeOrderID = beforeOrderId ?? ""
            $0.limit = Int32(limit ?? 0)
        }).invoke()
        return result.messages
    }
    
    func addMessage(chatObjectId: String, message: ChatMessage) async throws -> ChatMessage {
        let result = try await ClientCommands.chatAddMessage(.with {
            $0.chatObjectID = chatObjectId
            $0.message = message
        }).invoke()
        
        var message = message
        message.id = result.messageID
        return message
    }
    
    func subscribeLastMessages(chatObjectId: String, limit: Int?) async throws -> [ChatMessage] {
        let result = try await ClientCommands.chatSubscribeLastMessages(.with {
            $0.chatObjectID = chatObjectId
            $0.limit = Int32(limit ?? 0)
        }).invoke()
        return result.messages
    }
    
    func unsubscribeLastMessages(chatObjectId: String) async throws {
        try await ClientCommands.chatUnsubscribe(.with {
            $0.chatObjectID = chatObjectId
        }).invoke()
    }
}
