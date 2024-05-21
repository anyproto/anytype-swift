import Foundation
import Services

struct SpacePermissions: Equatable {
    let canBeShared: Bool
    let canStopSharing: Bool
    let canEdit: Bool
    let canLeave: Bool
    let canBeDelete: Bool
    let canBeArchive: Bool
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
        canBeDelete = (isOwner && (spaceView.spaceAccessType == .private || spaceView.spaceAccessType == .shared))
                        || (!isOwner && spaceView.accountStatus == .spaceRemoving)
        canBeArchive = spaceView.accountStatus == .spaceRemoving
        canCancelJoinRequest = spaceView.accountStatus == .spaceJoining
        canDeleteLink = isOwner && !isLocalMode
        canEditPermissions = isOwner && !isLocalMode
    }
}
