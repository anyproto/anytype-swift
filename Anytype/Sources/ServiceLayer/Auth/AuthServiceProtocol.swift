import BlocksModels

protocol AuthServiceProtocol {
    func createWallet() -> Result<String, AuthServiceError>
    func createAccount(name: String, imagePath: String, alphaInviteCode: String) -> Result<Void, CreateAccountServiceError>
    func walletRecovery(mnemonic: String) -> Result<Void, AuthServiceError>
    
    /// Recover account, called after wallet recovery. As soon as this func complete middleware send Event.Account.Show event.
    func accountRecover(onCompletion: @escaping (AuthServiceError?) -> ())
   
    func selectAccount(id: String) -> AccountStatus?
    func selectAccount(id: String, onCompletion: @escaping (AccountStatus?) -> ())
    
    /// Get mnemonic (recovery phrase) by entropy from qr code
    func mnemonicByEntropy(_ entropy: String) -> Result<String, Error>

    func logout(removeData: Bool, onCompletion: @escaping (Bool) -> ())
    func deleteAccount() -> AccountStatus?
    func restoreAccount() -> AccountStatus?
}
