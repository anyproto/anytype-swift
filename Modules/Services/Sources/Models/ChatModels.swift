import ProtobufMessages
import Foundation

public typealias ChatMessage = Anytype_Model_ChatMessage

public extension ChatMessage {
    var createdAtDate: Date {
        Date(timeIntervalSince1970: TimeInterval(createdAt))
    }
}
