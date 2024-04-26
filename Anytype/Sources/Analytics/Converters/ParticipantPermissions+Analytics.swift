import Foundation
import Services

extension ParticipantPermissions {
    var analyticsType: PermissionAnalyticsType {
        switch self {
        case .writer:
            return .write
        case .owner:
            return .owner
        case .reader:
            return .read
        case .noPermissions:
            return .noPermissions
        case .UNRECOGNIZED:
            return .unrecognized
        }
    }
}
