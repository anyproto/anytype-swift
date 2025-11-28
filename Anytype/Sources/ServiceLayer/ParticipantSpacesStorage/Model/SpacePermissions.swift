import Foundation
import Services

struct SpacePermissions: Equatable, Hashable {
    let canBeShared: Bool
    let canStopSharing: Bool
    let canEdit: Bool
    let canLeave: Bool
    let canBeDeleted: Bool
    let canBeArchived: Bool
    let canCancelJoinRequest: Bool
    let canDeleteLink: Bool
    let canEditPermissions: Bool
    let canApproveRequests: Bool
    let canChangeUxType: Bool
}

extension SpacePermissions {
    init(spaceView: SpaceView, participant: Participant?, isLocalMode: Bool) {
        
        let isOwner = participant?.isOwner ?? false
        let spaceAccessType = spaceView.spaceAccessType ?? .UNRECOGNIZED(0)
        let participantCanEdit = participant?.canEdit ?? false
        
        self.init(
            spaceView: spaceView,
            spaceAccessType: spaceAccessType,
            isOwner: isOwner,
            participantCanEdit: participantCanEdit,
            isLocalMode: isLocalMode
        )
    }
    
    init(spaceView: SpaceView, spaceAccessType: SpaceAccessType, isOwner: Bool, participantCanEdit: Bool, isLocalMode: Bool) {

        let isOneToOne = spaceView.uxType.isOneToOne

        canBeShared = isOwner && spaceAccessType.isSharable && !isLocalMode
        canStopSharing = isOwner && spaceAccessType.isShared && !isLocalMode
        canEdit = participantCanEdit
        canLeave = !isOwner && spaceView.isActive && !isLocalMode && !isOneToOne

        let baseCanBeDeleted: Bool
        if spaceView.localStatus == .loading {
            baseCanBeDeleted = true
        } else if isOwner {
            baseCanBeDeleted = spaceAccessType.isDeletable
        } else {
            baseCanBeDeleted = spaceView.accountStatus == .spaceRemoving
        }
        canBeDeleted = baseCanBeDeleted && !isOneToOne

        canBeArchived = spaceView.isActive
        canCancelJoinRequest = spaceView.accountStatus == .spaceJoining
        canDeleteLink = isOwner && !isLocalMode && !spaceView.uxType.isStream // we don't have revoke method for stream guest link now
        canEditPermissions = isOwner && !isLocalMode
        canApproveRequests = isOwner
        canChangeUxType = isOwner
    }
}
