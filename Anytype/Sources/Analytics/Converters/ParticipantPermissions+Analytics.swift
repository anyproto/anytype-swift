import Foundation
import Services

extension ParticipantPermissions {
    var analyticsType: PermissionAnalyticsType {
        switch self {
        case .writer, .owner:
            return .write
        case .reader, .noPermissions, .UNRECOGNIZED:
            return .read
        }
    }
}
