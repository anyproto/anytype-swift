import Foundation

enum AuthServiceError: Error, LocalizedError {
    case createWalletError
    case recoverWalletError
    case recoverAccountError
    case selectAccountError
    
    var errorDescription: String? {
        switch self {
        case .createWalletError: return "Error creating wallet"
        case .recoverWalletError: return "Error wallet recover account"
        case .recoverAccountError: return "Account recover error"
        case .selectAccountError: return "Error select account"
        }
    }
}
