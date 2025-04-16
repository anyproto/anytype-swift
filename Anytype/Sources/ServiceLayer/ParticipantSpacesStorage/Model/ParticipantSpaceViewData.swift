import Foundation
import Services

struct ParticipantSpaceViewData: Equatable, Identifiable {
    let spaceView: SpaceView
    let participant: Participant?
    let permissions: SpacePermissions
    
    var id: String { spaceView.id }
    
    // Calculate cache for make fast equitable on main thread
    private let storedHash: Int
    
    init(
        spaceView: SpaceView,
        participant: Participant?,
        permissions: SpacePermissions
    ) {
        self.spaceView = spaceView
        self.participant = participant
        self.permissions = permissions
        
        var hasher = Hasher()
        hasher.combine(spaceView)
        hasher.combine(participant)
        hasher.combine(permissions)
        self.storedHash = hasher.finalize()
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.storedHash == rhs.storedHash
    }
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
    
    func updateUnreadMessagesCount(_ count: Int) -> ParticipantSpaceViewData {
        ParticipantSpaceViewData(
            spaceView: spaceView.updateUnreadMessagesCount(count),
            participant: participant,
            permissions: permissions
        )
    }
}
