import Foundation
import ProtobufMessages
import AnytypeCore

public enum SpaceStatus {
    case unknown
    case loading
    case ok
    case missing
    case error
    case remoteWaitingDeletion
    case remoteDeleted
    case spaceDeleted
    case spaceActive
    case spaceJoining
    case spaceRemoving
}

public extension SpaceStatus {
    init(from status: Anytype_Model_SpaceStatus?) throws {
        switch status {
        case .unknown:
            self = .unknown
        case .loading:
            self = .loading
        case .ok:
            self = .ok
        case .missing:
            self = .missing
        case .error:
            self = .error
        case .remoteWaitingDeletion:
            self = .remoteWaitingDeletion
        case .remoteDeleted:
            self = .remoteDeleted
        case .spaceDeleted:
            self = .spaceDeleted
        case .spaceActive:
            self = .spaceActive
        case .spaceJoining:
            self = .spaceJoining
        case .spaceRemoving:
            self = .spaceRemoving
        case .UNRECOGNIZED(let value):
            anytypeAssertionFailure("UNRECOGNIZED Anytype_Model_SpaceStatus", info: ["status": "\(value)"])
            throw CommonConvertError.requiredFieldIsMissing
        case .none:
            throw CommonConvertError.requiredFieldIsMissing
        }
    }
    
    var toMiddleware: Anytype_Model_SpaceStatus {
        switch self {
        case .unknown: 
            return .unknown
        case .loading:
            return .loading
        case .ok:
            return .ok
        case .missing:
            return .missing
        case .error:
            return .error
        case .remoteWaitingDeletion:
            return .remoteWaitingDeletion
        case .remoteDeleted:
            return .remoteDeleted
        case .spaceDeleted:
            return .spaceDeleted
        case .spaceActive:
            return .spaceActive
        case .spaceJoining:
            return .spaceJoining
        case .spaceRemoving:
            return .spaceRemoving
        }
    }
}
