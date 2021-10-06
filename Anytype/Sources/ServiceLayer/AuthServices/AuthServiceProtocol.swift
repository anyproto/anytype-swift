import BlocksModels

typealias OnCompletion = (_ result: Result<BlockId, AuthServiceError>) -> Void
typealias OnCompletionWithEmptyResult = (_ result: Result<Void, AuthServiceError>) -> Void

/// Error that AuthService can throw
enum AuthServiceError: Error {
    case logoutError(message: String? = "Logout error")
    case loginError(message: String? = "Login error")
    case createWalletError(message: String? = "Error creating wallet")
    case createAccountError(message: String? = "Error creating account")
    case recoverWalletError(message: String? = "Error wallet recover account")
    case recoverAccountError(message: String? = "Error account recover")
    case selectAccountError(message: String? = "Error select account")
}

// Wallet may contain many accounts
protocol AuthServiceProtocol {
    func createWallet(onCompletion: @escaping OnCompletionWithEmptyResult)
    func createAccount(profile: CreateAccountRequest, alphaInviteCode: String) -> Result<BlockId, AuthServiceError>
    func walletRecovery(mnemonic: String, onCompletion: @escaping OnCompletionWithEmptyResult)
    
    /// Recover account, called after wallet recovery. As soon as this func complete middleware send Event.Account.Show event.
    func accountRecover(onCompletion: @escaping OnCompletionWithEmptyResult)
    
    func selectAccount(id: String) -> Result<BlockId, AuthServiceError>
    
    /// Get mnemonic (keychain phrase) by entropy from qr code
    func mnemonicByEntropy(_ entropy: String) -> Result<String, Error>

    /// Logout from the current account.  Accounts seed will be removed from keychain.
    func logout(completion: @escaping () -> Void)
}
