import Services

protocol AuthServiceProtocol: Sendable {
    func createWallet() async throws -> String
    func createAccount(name: String, iconOption: Int, imagePath: String) async throws -> AccountData
    func walletRecovery(mnemonic: String) async throws
    
    func accountRecover() async throws
   
    func selectAccount(id: String) async throws -> AccountData
    
    /// Get mnemonic (recovery phrase) by entropy from qr code
    func mnemonicByEntropy(_ entropy: String) async throws -> String

    func logout(removeData: Bool) async throws
    func deleteAccount() async throws -> AccountStatus
    func restoreAccount() async throws -> AccountStatus
}
