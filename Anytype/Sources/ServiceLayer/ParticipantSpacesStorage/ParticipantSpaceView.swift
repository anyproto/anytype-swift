import Foundation
import Services

struct ParticipantSpaceView: Equatable, Identifiable {
    let spaceView: SpaceView
    let participant: Participant?
    
    var id: String { spaceView.id }
}

extension ParticipantSpaceView {
    var canBeShared: Bool {
        spaceView.canBeShared(isOwner: participant?.isOwner ?? false)
    }
    
    var canEdit: Bool {
        participant?.canEdit ?? false
    }
    
    var canLeave: Bool {
        participant?.canLeave ?? false
    }
    
    var isOwner: Bool {
        participant?.isOwner ?? false
    }
}
