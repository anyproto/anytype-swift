import Foundation
import Services

struct ParticipantSpaceView: Equatable, Identifiable {
    let spaceView: SpaceView
    let participant: Participant?
    
    var id: String { spaceView.id }
}

extension ParticipantSpaceView {
    var canBeShared: Bool {
        spaceView.canBeShared(isOwner: isOwner)
    }
    
    var canStopSharing: Bool {
        spaceView.canStopShating(isOwner: isOwner)
    }
    
    var canEdit: Bool {
        participant?.canEdit ?? false
    }
    
    var canLeave: Bool {
        spaceView.canLeave(isOwner: isOwner)
    }
    
    var canBeDelete: Bool {
        spaceView.canBeDelete(isOwner: isOwner)
    }
    
    var isOwner: Bool {
        participant?.isOwner ?? false
    }
}
