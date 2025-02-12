import Foundation
import Services

struct ParticipantSpaceViewData: Equatable, Identifiable {
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
}
