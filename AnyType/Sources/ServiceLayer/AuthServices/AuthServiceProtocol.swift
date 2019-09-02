//
//  AuthServiceProtocol.swift
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
	case generateRecoveryPhraseError(message: String? = nil)
}

/// Service for auth in AnyType account
protocol AuthServiceProtocol {
	
	/// Login with account seed
	/// - Parameter seed: seed phrase
	/// - Parameter completion: Called on completion
	func login(with seed: String, completion: @escaping (_ error: Swift.Error?) -> Void)
	
	/// Logout from the current account.  Accounts seed will be removed from keychain.
	/// - Parameter completion: Called on completion
	func logout(completion: @escaping () -> Void)
	
	/// Create new wallet and account
	/// - Parameter onReceivingRecoveryPhrase: Called on completion with recovery wallet string or AuthServiceError.
	func createWalletAndAccount(onReceivingRecoveryPhrase: @escaping OnReceivingRecoveryPhrase)
	
	/// Generate recovery phrase
	/// - Parameter wordCount: word's count in recovery phrase
	func generateRecoveryPhrase(wordCount: Int?) throws -> String
	
	/// Create new wallet and account with generated recovery phrase
	/// - Parameter recoveryPhrase: recovery phrase (mnemonic phase)
	/// - Parameter onReceivingRecoveryPhrase: Called on completion with recovery wallet string or AuthServiceError.
	func createWalletAndAccount(with recoveryPhrase: String, onReceivingRecoveryPhrase: @escaping OnReceivingRecoveryPhrase)
}
