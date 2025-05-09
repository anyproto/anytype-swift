import Foundation
import ProtobufMessages

public protocol ChatServiceProtocol: AnyObject, Sendable {
    func getMessages(chatObjectId: String, beforeOrderId: String?, afterOrderId: String?, limit: Int?, includeBoundary: Bool) async throws -> [ChatMessage]
    func getMessagesByIds(chatObjectId: String, messageIds: [String]) async throws -> [ChatMessage]
    func addMessage(chatObjectId: String, message: ChatMessage) async throws -> String
    func updateMessage(chatObjectId: String, message: ChatMessage) async throws
    func subscribeLastMessages(chatObjectId: String, subId: String, limit: Int?) async throws -> ChatSubscribeLastMessagesResponse
    func unsubscribeLastMessages(chatObjectId: String, subId: String) async throws
    func subscribeToMessagePreviews(subId: String) async throws -> ChatSubscribeToMessagePreviewsResponse
    func unsubscribeFromMessagePreviews() async throws
    func toggleMessageReaction(chatObjectId: String, messageId: String, emoji: String) async throws
    func deleteMessage(chatObjectId: String, messageId: String) async throws
    func readMessages(
        chatObjectId: String,
        afterOrderId: String,
        beforeOrderId: String,
        type: ChatMessagesReadType,
        lastStateId: String
    ) async throws
    func unreadMessage(chatObjectId: String, afterOrderId: String, type: ChatUnreadReadType) async throws
}

public extension ChatServiceProtocol {
    func getMessages(chatObjectId: String, beforeOrderId: String, limit: Int, includeBoundary: Bool = false) async throws -> [ChatMessage] {
        try await getMessages(chatObjectId: chatObjectId, beforeOrderId: beforeOrderId, afterOrderId: nil, limit: limit, includeBoundary: includeBoundary)
    }
    func getMessages(chatObjectId: String, afterOrderId: String, limit: Int, includeBoundary: Bool = false) async throws -> [ChatMessage] {
        try await getMessages(chatObjectId: chatObjectId, beforeOrderId: nil, afterOrderId: afterOrderId, limit: limit, includeBoundary: includeBoundary)
    }
}

final class ChatService: ChatServiceProtocol {
    func getMessages(chatObjectId: String, beforeOrderId: String?, afterOrderId: String?, limit: Int?, includeBoundary: Bool) async throws -> [ChatMessage] {
        let result = try await ClientCommands.chatGetMessages(.with {
            $0.chatObjectID = chatObjectId
            $0.beforeOrderID = beforeOrderId ?? ""
            $0.afterOrderID = afterOrderId ?? ""
            $0.limit = Int32(limit ?? 0)
            $0.includeBoundary = includeBoundary
        }).invoke()
        return result.messages
    }
    
    func getMessagesByIds(chatObjectId: String, messageIds: [String]) async throws -> [ChatMessage] {
        let result = try await ClientCommands.chatGetMessagesByIds(.with {
            $0.chatObjectID = chatObjectId
            $0.messageIds = messageIds
        }).invoke()
        return result.messages
    }
    
    func addMessage(chatObjectId: String, message: ChatMessage) async throws -> String {
        let result = try await ClientCommands.chatAddMessage(.with {
            $0.chatObjectID = chatObjectId
            $0.message = message
        }).invoke()
        return result.messageID
    }
    
    func updateMessage(chatObjectId: String, message: ChatMessage) async throws {
        try await ClientCommands.chatEditMessageContent(.with {
            $0.chatObjectID = chatObjectId
            $0.messageID = message.id
            $0.editedMessage = message
        }).invoke()
    }
    
    func subscribeLastMessages(chatObjectId: String, subId: String, limit: Int?) async throws -> ChatSubscribeLastMessagesResponse {
        let result = try await ClientCommands.chatSubscribeLastMessages(.with {
            $0.chatObjectID = chatObjectId
            $0.subID = subId
            $0.limit = Int32(limit ?? 0)
        }).invoke()
        return result
    }
    
    func unsubscribeLastMessages(chatObjectId: String, subId: String) async throws {
        try await ClientCommands.chatUnsubscribe(.with {
            $0.chatObjectID = chatObjectId
            $0.subID = subId
        }).invoke()
    }
    
    func subscribeToMessagePreviews(subId: String) async throws -> ChatSubscribeToMessagePreviewsResponse {
        let result = try await ClientCommands.chatSubscribeToMessagePreviews(.with {
            $0.subID = subId
        }).invoke()
        return result
    }
    
    func unsubscribeFromMessagePreviews() async throws {
        try await ClientCommands.chatUnsubscribeFromMessagePreviews().invoke()
    }
    
    func toggleMessageReaction(chatObjectId: String, messageId: String, emoji: String) async throws {
        try await ClientCommands.chatToggleMessageReaction(.with {
            $0.chatObjectID = chatObjectId
            $0.messageID = messageId
            $0.emoji = emoji
        }).invoke()
    }
    
    func deleteMessage(chatObjectId: String, messageId: String) async throws {
        try await ClientCommands.chatDeleteMessage(.with {
            $0.chatObjectID = chatObjectId
            $0.messageID = messageId
        }).invoke()
    }
    
    func readMessages(
        chatObjectId: String,
        afterOrderId: String,
        beforeOrderId: String,
        type: ChatMessagesReadType,
        lastStateId: String
    ) async throws {
        try await ClientCommands.chatReadMessages(.with {
            $0.chatObjectID = chatObjectId
            $0.afterOrderID = afterOrderId
            $0.beforeOrderID = beforeOrderId
            $0.lastStateID = lastStateId
            $0.type = type
        }).invoke()
    }
    
    func unreadMessage(chatObjectId: String, afterOrderId: String, type: ChatUnreadReadType) async throws {
        try await ClientCommands.chatUnreadMessages(.with {
            $0.chatObjectID = chatObjectId
            $0.afterOrderID = afterOrderId
            $0.type = type
        }).invoke()
    }
}
