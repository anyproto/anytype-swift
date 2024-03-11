import Foundation
import Services

extension ParticipantPermissions {
    var title: String {
        switch self {
        case .reader:
            return Loc.SpaceShare.Permissions.reader
        case .writer:
            return Loc.SpaceShare.Permissions.writer
        case .owner:
            return Loc.SpaceShare.Permissions.owner
        case .noPermissions, .UNRECOGNIZED:
            return rawValue.description
        }
    }
}
