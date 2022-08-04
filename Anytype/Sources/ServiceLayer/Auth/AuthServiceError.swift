import Foundation
import ProtobufMessages

typealias RecoverAccountErrorCode = Anytype_Rpc.Account.Recover.Response.Error.Code

enum AuthServiceError: Error, LocalizedError {
    case createWalletError
    case recoverWalletError
    case recoverAccountError(code: RecoverAccountErrorCode)
    case selectAccountError
    
    var errorDescription: String? {
        switch self {
        case .createWalletError: return Loc.errorCreatingWallet
        case .recoverWalletError: return Loc.errorWalletRecoverAccount
        case .recoverAccountError(let code):
            switch code {
            case .accountIsDeleted:
                return Loc.accountIsDeleted
            case .badInput, .anotherAnytypeProcessIsRunning, .failedToCreateLocalRepo, .failedToRunNode, .failedToStopRunningNode, .unknownError, .noAccountsFound, .needToRecoverWalletFirst, .localRepoExistsButCorrupted, .walletRecoverNotPerformed:
                return Loc.accountRecoverError
            case .UNRECOGNIZED, .null:
                return Loc.accountRecoverErrorNoInternet
            }
        case .selectAccountError: return Loc.errorSelectAccount
        }
    }
}
