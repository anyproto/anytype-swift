import Foundation
import ProtobufMessages

public struct Notification: Sendable {
    public var id: String
    public var createTime: Date
    public var status: NotificationStatus
    public var isLocal: Bool
    public var payload: Anytype_Model_Notification.OneOf_Payload?
}

extension Anytype_Model_Notification {
    func asModel() -> Notification {
        Notification(
            id: id,
            createTime: Date(timeIntervalSince1970: TimeInterval(createTime)),
            status: status.asModel(),
            isLocal: isLocal,
            payload: payload
        )
    }
}
