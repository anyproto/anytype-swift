import Foundation
import Services

extension WalletRecoveryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .badInput: return Loc.Wallet.Recovery.Error.description
        case .unknownError: return Loc.unknownError
        }
    }
}
