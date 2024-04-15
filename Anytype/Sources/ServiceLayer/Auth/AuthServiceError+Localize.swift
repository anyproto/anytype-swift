import Foundation
import Services

extension AuthServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .createWalletError: return Loc.errorCreatingWallet
        case .recoverWalletError: return Loc.errorWalletRecoverVault
        case .recoverAccountError(let code):
            switch code {
            case .badInput, .unknownError, .needToRecoverWalletFirst:
                return Loc.vaultRecoverError
            case .UNRECOGNIZED, .null:
                return Loc.vaultRecoverErrorNoInternet
            }
        case .selectAccountError: return Loc.errorSelectVault
        }
    }
}
