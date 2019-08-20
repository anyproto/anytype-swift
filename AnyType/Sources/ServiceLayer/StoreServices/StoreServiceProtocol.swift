//
//  StoreServiceProtocol.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11/07/2019.
//  Copyright © 2019 AnyType. All rights reserved.
//


// MARK: - StoreServiceProtocol

/// Protocol for interaction with store
protocol StoreServiceProtocol {
	/// Obtain seed for public key
	/// - Parameter name: public key
	/// - Parameter keyChainPassword: keychain password
	/// - Returns: seed
	func obtainSeed(for name: String, keyChainPassword: String?) throws -> String
	/// Save seed to keychain
	/// - Parameter name: public key
	/// - Parameter seed: seed
	/// - Parameter keyChainPassword: keychain password that will protect seed
	func saveSeedForAccount(name: String, seed: String, keyChainPassword: String?) throws
	/// Check if seed exists for public key
	/// - Parameter publicKey: public key
	/// - Returns: true if seed exists otherwise false
	func containsSeed(for publicKey: String) -> Bool
	/// Remove seed
	/// - Parameter publicKey: public key
	func removeSeed(for publicKey: String, keyChainPassword: String?) throws
}
