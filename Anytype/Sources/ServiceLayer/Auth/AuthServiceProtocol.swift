import Services

protocol AuthServiceProtocol {
    func createWallet() async throws -> String
    func createAccount(name: String, imagePath: String) async throws
    func walletRecovery(mnemonic: String) async throws
    
    /// Recover account, called after wallet recovery. As soon as this func complete middleware send Event.Account.Show event.
    func accountRecover(onCompletion: @escaping (AuthServiceError?) -> ())
    func accountRecover() async throws
   
    func selectAccount(id: String) async throws -> AccountStatus
    
    /// Get mnemonic (recovery phrase) by entropy from qr code
    func mnemonicByEntropy(_ entropy: String) async throws -> String

    func logout(removeData: Bool, onCompletion: @escaping (Bool) -> ())
    func deleteAccount() async throws -> AccountStatus
    func restoreAccount() async throws -> AccountStatus
}
