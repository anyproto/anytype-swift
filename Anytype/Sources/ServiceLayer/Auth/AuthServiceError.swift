import Foundation

enum AuthServiceError: Error, LocalizedError {
    case createWalletError
    case recoverWalletError
    case recoverAccountError
    case selectAccountError
    
    var errorDescription: String? {
        switch self {
        case .createWalletError: return "Error creating wallet".localized
        case .recoverWalletError: return "Error wallet recover account".localized
        case .recoverAccountError: return "Account recover error".localized
        case .selectAccountError: return "Error select account".localized
        }
    }
}
