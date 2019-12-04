//
//  AuthServiceProtocol.swift
//  AnyType
//
//  Created by Denis Batvinkin on 22.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

typealias OnCompletion = (_ result: Result<String, AuthServiceError>) -> Void

/// Error that AuthService can throw
enum AuthServiceError: Error {
    case logoutError(message: String? = "Logout error")
    case loginError(message: String? = "Login error")
    case createWalletError(message: String? = "Error creating wallet")
    case createAccountError(message: String? = "Error creating account")
}

/// Service for auth in AnyType account
protocol AuthServiceProtocol {

    /// Loging with recovery phrase
    /// - Parameter recoveryPhrase: recovery phrase
    /// - Parameter completion: Called on completion
    func login(recoveryPhrase: String, completion: @escaping (_ error: Swift.Error?) -> Void)
    
    /// Logout from the current account.  Accounts seed will be removed from keychain.
    /// - Parameter completion: Called on completion
    func logout(completion: @escaping () -> Void)
    
    /// Create new account for current wallet
    /// - Parameter profile: User profile
    /// - Parameter OnCompletion: Called on completion with account id or AuthServiceError.
    func createAccount(profile: AuthModels.CreateAccount.Request, onCompletion: @escaping OnCompletion)
    
    /// Create new wallet
    /// - Parameters:
    /// - onCompletion: Called on completion with recovery wallet string or AuthServiceError.
    func createWallet(in path: String, onCompletion: @escaping OnCompletion)

}
