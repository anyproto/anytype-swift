import ProtobufMessages

public enum SyncStatus: Sendable {
    case unknown
    case offline
    case syncing
    case synced
    case failed
    case incompatibleVersion

    public init?(_ model: Anytype_Event.Status.Thread.SyncStatus) {
        switch model {
        case .unknown:
            self = .unknown
        case .offline:
            self = .offline
        case .syncing:
            self = .syncing
        case .synced:
            self = .synced
        case .failed:
            self = .failed
        case .incompatibleVersion:
            self = .incompatibleVersion
        case .UNRECOGNIZED:
            return nil
        }
    }
}
