import Foundation
import ProtobufMessages

public enum NotificationStatus {
    case created
    case shown
    case read
    case replied
    case unrecognized
}

extension Anytype_Model_Notification.Status {
    func asModel() -> NotificationStatus {
        switch self {
        case .created: return .created
        case .shown: return .shown
        case .read: return .read
        case .replied: return .replied
        case .UNRECOGNIZED: return .unrecognized
        }
    }
}
