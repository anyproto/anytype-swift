//
//  AuthService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 22.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

typealias OnReceivingRecoveryPhrase = (_ result: Result<String, AuthServiceError>) -> Void

/// Error that AuthService can throw
enum AuthServiceError: Error {
	case logoutError(message: String? = nil)
	case loginError(message: String? = nil)
	case createWalletError(message: String? = nil)
}

/// Service for auth in AnyType account
protocol AuthService {
	
	/// Login with account seed
	/// - Parameter seed: seed phrase
	/// - Throws: AuthServiceError error
	func login(with seed: String) throws
	
	/// Logout from the current account.  Accounts seed will be removed from keychain.
	/// - Throws: AuthServiceError error
	func logout() throws
	
	/// Create new wallet and account
	/// - Parameter onReceivingRecoveryPhrase: Called on completion with recovery wallet string or AuthServiceError.
	func createWalletAndAccount(onReceivingRecoveryPhrase: OnReceivingRecoveryPhrase)
}
