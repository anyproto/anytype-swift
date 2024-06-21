import Foundation
import ProtobufMessages

public enum NotificationActionType: Sendable {
    case close
}

extension NotificationActionType {
    func toMiddleware() -> Anytype_Model_Notification.ActionType {
        switch self {
        case .close:
            return .close
        }
    }
}
