import Foundation
import Services

struct SpacePermissions: Equatable {
    let canBeShared: Bool
    let canStopSharing: Bool
    let canEdit: Bool
    let canLeave: Bool
    let canBeDeleted: Bool
    let canBeArchived: Bool
    let canCancelJoinRequest: Bool
    let canDeleteLink: Bool
    let canEditPermissions: Bool
}

extension SpacePermissions {
    init(spaceView: SpaceView, participant: Participant?, isLocalMode: Bool) {
        
        let isOwner = participant?.isOwner ?? false
        
        canBeShared = isOwner && (spaceView.spaceAccessType == .shared || spaceView.spaceAccessType == .private) && !isLocalMode
        canStopSharing = isOwner && (spaceView.spaceAccessType == .shared) && !isLocalMode
        canEdit = participant?.canEdit ?? false
        canLeave = !isOwner && spaceView.isActive && !isLocalMode
        canBeDeleted = (isOwner && (spaceView.spaceAccessType == .private || spaceView.spaceAccessType == .shared))
                        || (!isOwner && spaceView.accountStatus == .spaceRemoving)
        canBeArchived = spaceView.isActive
        canCancelJoinRequest = spaceView.accountStatus == .spaceJoining
        canDeleteLink = isOwner && !isLocalMode
        canEditPermissions = isOwner && !isLocalMode
    }
}
