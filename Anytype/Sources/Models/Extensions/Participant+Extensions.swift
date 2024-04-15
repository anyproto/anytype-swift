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
    
    var grandTitle: String {
        switch self {
        case .reader, .noPermissions, .UNRECOGNIZED:
            return Loc.SpaceShare.Permissions.Grand.view
        case .writer, .owner:
            return Loc.SpaceShare.Permissions.Grand.edit
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
    
    var title: String {
        localName.withPlaceholder
    }
    
    var isOwner: Bool {
        permission == .owner
    }
    
    var canEdit: Bool {
        permission.canEdit
    }
}
