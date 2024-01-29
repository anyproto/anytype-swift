import Foundation
import ProtobufMessages

public enum NotificationActionType {
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
