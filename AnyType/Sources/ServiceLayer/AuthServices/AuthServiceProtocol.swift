//
//  AuthServiceProtocol.swift
//  AnyType
//
//  Created by Denis Batvinkin on 22.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

typealias OnCompletion = (_ result: Result<String, AuthServiceError>) -> Void
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
    func createWallet(in path: String, onCompletion: @escaping OnCompletionWithEmptyResult)
    
    /// Create new account for current wallet
    /// - Parameter profile: User profile
    /// - Parameter OnCompletion: Called on completion with account id or AuthServiceError.
    func createAccount(profile: CreateAccountRequest, alphaInviteCode: String, onCompletion: @escaping OnCompletion)
    
    /// Recover wallet with mnemonic phrase
    /// - Parameters:
    ///   - mnemonic: String mnemonic phrase
    ///   - path: Path to wallet repo
    ///   - onCompletion: Called on completion
    func walletRecovery(mnemonic: String, path: String, onCompletion: @escaping OnCompletionWithEmptyResult)
    
    /// Recover account, called after wallet recovery. As soon as this func complete middleware send Event.Account.Show event.
    func accountRecover(onCompletion: @escaping OnCompletionWithEmptyResult)
    
    /// Select account from wallet
    /// - Parameters:
    ///   - id: acount hash id
    ///   - path: path to wallet
    ///   - onCompletion: Called on completion.
    func selectAccount(id: String, path: String, onCompletion: @escaping OnCompletion)
    
    /// Get mnemonic (keychain phrase) by entropy from qr code
    func mnemonicByEntropy(_ entropy: String, completion: @escaping OnCompletion)

    /// Logout from the current account.  Accounts seed will be removed from keychain.
    func logout(completion: @escaping () -> Void)
}
