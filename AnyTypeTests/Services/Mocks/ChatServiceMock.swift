import Foundation
import Services
@testable import Anytype

final class ChatServiceMock: ChatServiceProtocol, @unchecked Sendable {

    // MARK: - subscribeLastMessages

    struct SubscribeLastMessagesCall: Sendable {
        let chatObjectId: String
        let subId: String
        let limit: Int?
    }

    var subscribeLastMessagesCalls: [SubscribeLastMessagesCall] = []
    var subscribeLastMessagesMessageCount: Int32 = 0
    var subscribeLastMessagesError: Error?

    func subscribeLastMessages(chatObjectId: String, subId: String, limit: Int?) async throws -> ChatSubscribeLastMessagesResponse {
        subscribeLastMessagesCalls.append(.init(chatObjectId: chatObjectId, subId: subId, limit: limit))
        if let error = subscribeLastMessagesError {
            throw error
        }
        var response = ChatSubscribeLastMessagesResponse()
        response.messageCount = subscribeLastMessagesMessageCount
        return response
    }

    // MARK: - unsubscribeLastMessages

    struct UnsubscribeLastMessagesCall: Sendable {
        let chatObjectId: String
        let subId: String
    }

    var unsubscribeLastMessagesCalls: [UnsubscribeLastMessagesCall] = []

    func unsubscribeLastMessages(chatObjectId: String, subId: String) async throws {
        unsubscribeLastMessagesCalls.append(.init(chatObjectId: chatObjectId, subId: subId))
    }

    // MARK: - Unused stubs

    func getMessages(chatObjectId: String, beforeOrderId: String?, afterOrderId: String?, limit: Int?, includeBoundary: Bool) async throws -> [ChatMessage] {
        fatalError("ChatServiceMock.getMessages not stubbed")
    }

    func getMessagesByIds(chatObjectId: String, messageIds: [String]) async throws -> [ChatMessage] {
        fatalError("ChatServiceMock.getMessagesByIds not stubbed")
    }

    func addMessage(chatObjectId: String, message: ChatMessage) async throws -> String {
        fatalError("ChatServiceMock.addMessage not stubbed")
    }

    func updateMessage(chatObjectId: String, message: ChatMessage) async throws {
        fatalError("ChatServiceMock.updateMessage not stubbed")
    }

    func subscribeToMessagePreviews(subId: String) async throws -> ChatSubscribeToMessagePreviewsResponse {
        fatalError("ChatServiceMock.subscribeToMessagePreviews not stubbed")
    }

    func unsubscribeFromMessagePreviews() async throws {
        fatalError("ChatServiceMock.unsubscribeFromMessagePreviews not stubbed")
    }

    func toggleMessageReaction(chatObjectId: String, messageId: String, emoji: String) async throws -> Bool {
        fatalError("ChatServiceMock.toggleMessageReaction not stubbed")
    }

    func deleteMessage(chatObjectId: String, messageId: String) async throws {
        fatalError("ChatServiceMock.deleteMessage not stubbed")
    }

    func readMessages(chatObjectId: String, afterOrderId: String, beforeOrderId: String, type: ChatMessagesReadType, lastStateId: String) async throws {
        fatalError("ChatServiceMock.readMessages not stubbed")
    }

    func unreadMessage(chatObjectId: String, afterOrderId: String, type: ChatUnreadReadType) async throws {
        fatalError("ChatServiceMock.unreadMessage not stubbed")
    }

    func readAllMessages() async throws {
        fatalError("ChatServiceMock.readAllMessages not stubbed")
    }

    func readReactions(chatObjectId: String, orderId: String) async throws {
        fatalError("ChatServiceMock.readReactions not stubbed")
    }

    func addDiscussion(objectId: String) async throws -> String {
        fatalError("ChatServiceMock.addDiscussion not stubbed")
    }

    func addNotificationSubscriber(chatObjectId: String, identity: String) async throws {
        fatalError("ChatServiceMock.addNotificationSubscriber not stubbed")
    }

    func removeNotificationSubscriber(chatObjectId: String, identity: String) async throws {
        fatalError("ChatServiceMock.removeNotificationSubscriber not stubbed")
    }
}
