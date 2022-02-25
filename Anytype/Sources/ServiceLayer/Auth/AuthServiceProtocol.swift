import BlocksModels

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

protocol AuthServiceProtocol {
    func createWallet() -> Result<String, AuthServiceError>
    func createAccount(name: String, imagePath: String, alphaInviteCode: String) -> Result<Void, Error>
    func walletRecovery(mnemonic: String) -> Result<Void, AuthServiceError>
    
    /// Recover account, called after wallet recovery. As soon as this func complete middleware send Event.Account.Show event.
    func accountRecover(onCompletion: @escaping (AuthServiceError?) -> ())
   
    func selectAccount(id: String) -> Bool
    func selectAccount(id: String, onCompletion: @escaping (Bool) -> ())
    
    /// Get mnemonic (keychain phrase) by entropy from qr code
    func mnemonicByEntropy(_ entropy: String) -> Result<String, Error>

    /// Accounts seed will be removed from keychain.
    func logout()
}
