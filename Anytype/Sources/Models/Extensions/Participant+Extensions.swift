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
    
    var canEdit: Bool {
        switch self {
        case .reader, .noPermissions, .UNRECOGNIZED:
            return false
        case .writer, .owner:
            return true
        }
    }
}

extension Participant {
    var canLeave: Bool {
        return (permission == .reader || permission == .writer) && status == .active
    }
    
    var isOwner: Bool {
        return permission == .owner
    }
}
