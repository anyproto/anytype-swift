import Foundation
import ProtobufMessages

public enum WalletRecoveryError: Error {
    case badInput
    case unknownError
}

extension Anytype_Rpc.Wallet.Recover.Response.Error {
    var asError: WalletRecoveryError {
        switch code {
        case .badInput:
            return .badInput
        default:
            return .unknownError
        }
    }
}
