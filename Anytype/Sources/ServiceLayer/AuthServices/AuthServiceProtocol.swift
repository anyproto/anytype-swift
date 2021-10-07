import BlocksModels

enum AuthServiceError: Error, LocalizedError {
    case logoutError
    case loginError
    case createWalletError
    case createAccountError
    case recoverWalletError
    case recoverAccountError
    case selectAccountError
    
    var errorDescription: String? {
        switch self {
        case .logoutError: return "Logout error"
        case .loginError: return "Login error"
        case .createWalletError: return "Error creating wallet"
        case .createAccountError: return "Error creating account"
        case .recoverWalletError: return "Error wallet recover account"
        case .recoverAccountError: return "Account recover error"
        case .selectAccountError: return "Error select account"
        }
    }
}

// Wallet may contain many accounts
protocol AuthServiceProtocol {
    func createWallet() -> Result<String, AuthServiceError>
    func createAccount(profile: CreateAccountRequest, alphaInviteCode: String) -> Result<BlockId, AuthServiceError>
    func walletRecovery(mnemonic: String) -> Result<Void, AuthServiceError>
    
    /// Recover account, called after wallet recovery. As soon as this func complete middleware send Event.Account.Show event.
    func accountRecover() -> AuthServiceError?
    
    func selectAccount(id: String) -> Result<BlockId, AuthServiceError>
    
    /// Get mnemonic (keychain phrase) by entropy from qr code
    func mnemonicByEntropy(_ entropy: String) -> Result<String, Error>

    /// Logout from the current account.  Accounts seed will be removed from keychain.
    func logout(completion: @escaping () -> Void)
}
