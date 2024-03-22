import Foundation
import Services

struct ParticipantSpaceView: Equatable, Identifiable {
    let spaceView: SpaceView
    let participant: Participant?
    
    var id: String { spaceView.id }
}

extension ParticipantSpaceView {
    func activeSpaceView() -> ParticipantActiveSpaceView? {
        guard let participant, spaceView.isActive else { return nil }
        return ParticipantActiveSpaceView(spaceView: spaceView, participant: participant)
    }
}

struct ParticipantActiveSpaceView: Equatable, Identifiable {
    let spaceView: SpaceView
    let participant: Participant
    
    var id: String { spaceView.id }
}

extension ParticipantActiveSpaceView {
    var canBeShared: Bool {
        spaceView.canBeShared(isOwner: participant.isOwner)
    }
}
