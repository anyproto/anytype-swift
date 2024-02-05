import Foundation
import ProtobufMessages

public enum AccountDeleteError: Error {
    case unableToConnect
    case unknownError
}

extension Anytype_Rpc.Account.Delete.Response.Error {
    var asError: AccountDeleteError {
        switch code {
        case .unableToConnect:
            return .unableToConnect
        default:
            return .unknownError
        }
    }
}
