import Foundation
import ProtobufMessages

enum AccountDeleteError: Error, LocalizedError {
    case unableToConnect
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .unableToConnect: return Loc.Error.unableToConnect
        case .unknownError: return Loc.unknownError
        }
    }
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
