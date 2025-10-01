import Foundation

extension SpacePermissions {
    static func mock() -> Self {
        SpacePermissions(
            canBeShared: Bool.random(),
            canStopSharing: Bool.random(),
            canEdit: Bool.random(),
            canLeave: Bool.random(),
            canBeDeleted: Bool.random(),
            canBeArchived: Bool.random(),
            canCancelJoinRequest: Bool.random(),
            canDeleteLink: Bool.random(),
            canEditPermissions: Bool.random(),
            canApproveRequests: Bool.random(),
            canChangeUxType: Bool.random()
        )
    }
}
