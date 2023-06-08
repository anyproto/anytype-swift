import Foundation
import ProtobufMessages

enum SelectAccountError: Error {
    case failedToFindAccountInfo
}

extension Anytype_Rpc.Account.Select.Response.Error {
    var asError: SelectAccountError? {
        switch code {
        case .failedToFindAccountInfo:
            return .failedToFindAccountInfo
        default:
            return nil
        }
    }
}
