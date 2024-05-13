import Foundation
import Services

struct ParticipantSpaceView: Equatable, Identifiable {
    let spaceView: SpaceView
    let participant: Participant?
    let permissions: SpacePermissions
    
    var id: String { spaceView.id }
}

extension ParticipantSpaceView {
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
    
    var canBeDelete: Bool {
        permissions.canBeDelete
    }
    
    var canCancelJoinRequest: Bool {
        permissions.canCancelJoinRequest
    }
    
    var canStopShare: Bool {
        permissions.canStopShare
    }
    
    var canBeArchive: Bool {
        permissions.canBeArchive
    }
    
    var isOwner: Bool {
        participant?.isOwner ?? false
    }
}
