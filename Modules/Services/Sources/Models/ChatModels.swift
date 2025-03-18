import ProtobufMessages
import Foundation

public typealias ChatMessage = Anytype_Model_ChatMessage
public typealias ChatMessageAttachment = Anytype_Model_ChatMessage.Attachment
public typealias ChatMessageAttachmentType = Anytype_Model_ChatMessage.Attachment.Type
public typealias ChatMessageContent = Anytype_Model_ChatMessage.MessageContent
public typealias ChatState = Anytype_Model_ChatState
public typealias ChatMessagesReadType = Anytype_Rpc.Chat.ReadMessages.ReadType

public extension ChatMessage {
    var createdAtDate: Date {
        Date(timeIntervalSince1970: TimeInterval(createdAt))
    }
}
