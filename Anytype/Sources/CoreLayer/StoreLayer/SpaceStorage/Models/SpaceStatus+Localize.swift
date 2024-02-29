import Foundation
import Services

extension SpaceStatus {
    var name: String {
        switch self {
        case .unknown:
            return Loc.Space.Status.unknown
        case .loading:
            return Loc.Space.Status.loading
        case .ok:
            return Loc.Space.Status.ok
        case .missing:
            return Loc.Space.Status.missing
        case .error:
            return Loc.Space.Status.error
        case .remoteWaitingDeletion:
            return Loc.Space.Status.remoteWaitingDeletion
        case .remoteDeleted:
            return Loc.Space.Status.remoteDeleted
        case .spaceDeleted:
            return Loc.Space.Status.spaceDeleted
        case .spaceActive:
            return Loc.Space.Status.spaceActive
        case .spaceJoining:
            return Loc.Space.Status.spaceJoining
        case .spaceRemoving:
            return Loc.Space.Status.spaceRemoving
        case .UNRECOGNIZED:
            return Loc.Space.Status.unknown
        }
    }
}
