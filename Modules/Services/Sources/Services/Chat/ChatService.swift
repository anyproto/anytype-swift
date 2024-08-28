import Foundation
import ProtobufMessages

public protocol ChatServiceProtocol: AnyObject {
    func getMessages(chatObjectId: String) async throws -> [ChatMessage]
}

final class ChatService: ChatServiceProtocol {
    func getMessages(chatObjectId: String) async throws -> [ChatMessage] {
        let result = try await ClientCommands.chatGetMessages(.with {
            $0.chatObjectID = chatObjectId
        }).invoke()
        return result.messages
    }
}
