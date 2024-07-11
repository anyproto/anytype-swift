import ProtobufMessages
import Foundation


extension Anytype_Event.Space.SyncError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .null:
            nil
        case .storageLimitExceed:
            Loc.SyncStatus.Error.storageLimitExceed
        case .incompatibleVersion:
            Loc.SyncStatus.Error.incompatibleVersion
        case .networkError:
            Loc.SyncStatus.Error.networkError
        case .UNRECOGNIZED:
            Loc.SyncStatus.Error.unrecognized
        }
    }
}
