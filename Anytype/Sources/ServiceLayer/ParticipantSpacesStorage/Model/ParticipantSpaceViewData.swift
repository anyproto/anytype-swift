import Foundation
import Services
import StoredHashMacro

@StoredHash
struct ParticipantSpaceViewData: Equatable, Identifiable, Hashable {
    let spaceView: SpaceView
    let participant: Participant?
    let permissions: SpacePermissions
    
    var id: String { spaceView.id }
}

extension ParticipantSpaceViewData {
    var canBeShared: Bool {
        permissions.canBeShared
    }
    
    var canStopSharing: Bool {
        permissions.canStopSharing
    }
    
    var canEdit: Bool {
        permissions.canEdit
    }

    var canLeave: Bool {
        permissions.canLeave
    }
    
    var canBeDeleted: Bool {
        permissions.canBeDeleted
    }
    
    var canCancelJoinRequest: Bool {
        permissions.canCancelJoinRequest
    }
    
    var canBeArchived: Bool {
        permissions.canBeArchived
    }
    
    var isOwner: Bool {
        participant?.isOwner ?? false
    }

    var canManageChannelPins: Bool {
        actorPermission == .owner || actorPermission == .admin
    }

    var canSetHomepage: Bool {
        permissions.canSetHomepage
    }
}

extension ParticipantSpaceViewData {
    private var actorPermission: ParticipantPermissions {
        participant?.permission ?? .noPermissions
    }

    func canShowRoleMenu(target: Participant) -> Bool {
        guard target.permission != .owner else { return false }
        guard target.identity != participant?.identity else { return false }
        switch actorPermission {
        case .owner: return true
        case .admin: return target.permission != .admin
        default:     return false
        }
    }

    func canPromoteToAdmin(target: Participant) -> Bool {
        actorPermission == .owner
            && target.permission != .admin
            && target.permission != .owner
    }

    func canChangeRole(target: Participant) -> Bool {
        guard target.permission != .owner else { return false }
        switch actorPermission {
        case .owner: return true
        case .admin: return target.permission == .reader || target.permission == .writer
        default:     return false
        }
    }

    func canRemove(target: Participant) -> Bool {
        guard target.permission != .owner else { return false }
        guard target.identity != participant?.identity else { return false }
        switch actorPermission {
        case .owner: return true
        case .admin: return target.permission != .admin
        default:     return false
        }
    }
}
