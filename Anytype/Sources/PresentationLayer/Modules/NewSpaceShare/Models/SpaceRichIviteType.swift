import Services

// Our internal invite type. Middleware does not distinguish between editor and viewer invites
enum SpaceRichIviteType: String, CaseIterable, Identifiable {
    case editor
    case viewer
    case requestAccess
    case disabled
    
    var id: String { rawValue }
    
    var isShared: Bool {
        switch self {
        case .editor, .viewer, .requestAccess:
            true
        case .disabled:
            false
        }
    }
    
    var analyticsValue: ClickShareSpaceNewLinkType? {
        switch self {
        case .editor:
            .editor
        case .viewer:
            .viewer
        case .requestAccess:
            .manual
        case .disabled:
            nil
        }
    }
}

extension SpaceInvite {
    var richInviteType: SpaceRichIviteType? {
        switch inviteType {
        case .member:
            .requestAccess
        case .none:
            .disabled
        case .withoutApprove:
            switch permissions {
            case .reader:
                .viewer
            case .writer:
                .editor
            case .owner, .noPermissions, .UNRECOGNIZED, .none:
                nil
            }
        case .guest, .UNRECOGNIZED:
            nil
        }
    }
}


