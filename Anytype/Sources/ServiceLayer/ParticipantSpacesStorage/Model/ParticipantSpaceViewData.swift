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

    /// Single source of truth for the IOS-5864 Pin-to-channel / Unpin-from-channel
    /// gate. Owner-only today — middleware has no Admin role. When/if MW adds
    /// Admin, widen this predicate in one spot.
    var canManageChannelPins: Bool {
        isOwner
    }
    
    var canChangeUxType: Bool {
        permissions.canChangeUxType
    }

    var canSetHomepage: Bool {
        permissions.canSetHomepage
    }
}
