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
        case .createWalletError: return "Error creating wallet".localized
        case .recoverWalletError: return "Error wallet recover account".localized
        case .recoverAccountError(let code):
            switch code {
            case .accountIsDeleted:
                return "Account is deleted".localized
            case .badInput, .anotherAnytypeProcessIsRunning, .failedToCreateLocalRepo, .failedToRunNode, .failedToStopRunningNode, .unknownError, .noAccountsFound, .needToRecoverWalletFirst, .localRepoExistsButCorrupted, .walletRecoverNotPerformed:
                return "Account recover error".localized
            case .UNRECOGNIZED, .null:
                return "Account recover error no internet".localized
            }
        case .selectAccountError: return "Error select account".localized
        }
    }
}
