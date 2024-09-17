import ProtobufMessages
import Foundation

public typealias ChatMessage = Anytype_Model_ChatMessage
public typealias ChatMessageAttachment = Anytype_Model_ChatMessage.Attachment
public typealias ChatMessageContent = Anytype_Model_ChatMessage.MessageContent

public extension ChatMessage {
    var createdAtDate: Date {
        Date(timeIntervalSince1970: TimeInterval(createdAt))
    }
}
