import Foundation
import Services

extension AuthServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .createWalletError: return Loc.errorCreatingWallet
        case .recoverWalletError: return Loc.errorWalletRecoverAccount
        case .recoverAccountError(let code):
            switch code {
            case .badInput, .unknownError, .needToRecoverWalletFirst:
                return Loc.accountRecoverError
            case .UNRECOGNIZED, .null:
                return Loc.accountRecoverErrorNoInternet
            }
        case .selectAccountError: return Loc.errorSelectAccount
        }
    }
}
