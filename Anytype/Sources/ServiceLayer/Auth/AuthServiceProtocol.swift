import BlocksModels

protocol AuthServiceProtocol {
    func createWallet() -> Result<String, AuthServiceError>
    func createAccount(name: String, imagePath: String, alphaInviteCode: String) -> Result<Void, CreateAccountServiceError>
    func walletRecovery(mnemonic: String) -> Result<Void, AuthServiceError>
    
    /// Recover account, called after wallet recovery. As soon as this func complete middleware send Event.Account.Show event.
    func accountRecover(onCompletion: @escaping (AuthServiceError?) -> ())
   
    func selectAccount(id: String) -> Bool
    func selectAccount(id: String, onCompletion: @escaping (Bool) -> ())
    
    /// Get mnemonic (keychain phrase) by entropy from qr code
    func mnemonicByEntropy(_ entropy: String) -> Result<String, Error>

    /// Accounts seed will be removed from keychain.
    func logout() -> Bool
    
    func deleteAccount() -> AccountStatus?
}
