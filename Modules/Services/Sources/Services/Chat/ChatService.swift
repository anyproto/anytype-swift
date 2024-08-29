import Foundation
import ProtobufMessages

public protocol ChatServiceProtocol: AnyObject {
    func getMessages(chatObjectId: String, beforeMessageId: String?, limit: Int?) async throws -> [ChatMessage]
}

final class ChatService: ChatServiceProtocol {
    func getMessages(chatObjectId: String, beforeMessageId: String?, limit: Int?) async throws -> [ChatMessage] {
        let result = try await ClientCommands.chatGetMessages(.with {
            $0.chatObjectID = chatObjectId
            $0.beforeOrderID = beforeMessageId ?? ""
            $0.limit = Int32(limit ?? 0)
        }).invoke()
        return result.messages
    }
}
