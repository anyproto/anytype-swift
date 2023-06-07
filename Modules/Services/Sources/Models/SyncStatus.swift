import ProtobufMessages

public enum SyncStatus {
    case unknown
    case offline
    case syncing
    case synced
    case failed

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
        case .failed, .incompatibleVersion:
            self = .failed
        case .UNRECOGNIZED:
            return nil
        }
    }
}
