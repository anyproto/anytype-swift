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
    /// Create new wallet
    func createWallet(onCompletion: @escaping OnCompletionWithEmptyResult)
    
    /// Create new account for current wallet
    /// - Parameter profile: User profile
    /// - Parameter OnCompletion: Called on completion with account id or AuthServiceError.
    func createAccount(profile: CreateAccountRequest, alphaInviteCode: String, onCompletion: @escaping OnCompletion)
    
    /// Recover wallet with mnemonic phrase
    /// - Parameters:
    ///   - mnemonic: String mnemonic phrase
    ///   - onCompletion: Called on completion
    func walletRecovery(mnemonic: String, onCompletion: @escaping OnCompletionWithEmptyResult)
    
    /// Recover account, called after wallet recovery. As soon as this func complete middleware send Event.Account.Show event.
    func accountRecover(onCompletion: @escaping OnCompletionWithEmptyResult)
    
    func selectAccount(id: String) -> Result<BlockId, AuthServiceError>
    
    /// Get mnemonic (keychain phrase) by entropy from qr code
    func mnemonicByEntropy(_ entropy: String, completion: @escaping OnCompletion)

    /// Logout from the current account.  Accounts seed will be removed from keychain.
    func logout(completion: @escaping () -> Void)
}
