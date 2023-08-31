import Foundation
import ProtobufMessages

enum SelectAccountError: Error {
    case failedToFindAccountInfo
    case failedToFetchRemoteNodeHasIncompatibleProtoVersion
}

extension Anytype_Rpc.Account.Select.Response.Error {
    var asError: SelectAccountError? {
        switch code {
        case .failedToFindAccountInfo:
            return .failedToFindAccountInfo
        case .failedToFetchRemoteNodeHasIncompatibleProtoVersion:
            return .failedToFetchRemoteNodeHasIncompatibleProtoVersion
        default:
            return nil
        }
    }
}
