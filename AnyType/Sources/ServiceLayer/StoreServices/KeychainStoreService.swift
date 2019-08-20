//
//  KeychainStoreService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//


private enum StoreServiceConstants {
	static let serviceName = "com.AnyType.seed"
}

/// Keychain store serivce
final class KeychainStoreService {
    static let shared = KeychainStoreService()
	
	private let keychainStore = KeychainStore()
}

// MARK: - StoreServiceProtocol implementaion

extension KeychainStoreService: StoreServiceProtocol {
	
	func containsSeed(for publicKey: String) -> Bool {
		let seedQuery = GenericPasswordQueryable(account: publicKey, service: StoreServiceConstants.serviceName)
		
		return keychainStore.contains(queryable: seedQuery)
	}
	
	func removeSeed(for publicKey: String, keyChainPassword: String? = nil) throws {
		let seedQuery = GenericPasswordQueryable(account: publicKey, service: StoreServiceConstants.serviceName, keyChainPassword: keyChainPassword)
		try keychainStore.removeItem(queryable: seedQuery)
	}
	
	func obtainSeed(for name: String, keyChainPassword: String? = nil) throws -> String {
		let seedQuery = GenericPasswordQueryable(account: name, service: StoreServiceConstants.serviceName, keyChainPassword: keyChainPassword)
		let seed = try keychainStore.retreiveItem(queryable: seedQuery)
		
		return seed
	}
	
	func saveSeedForAccount(name: String, seed: String, keyChainPassword: String? = nil) throws {
		let seedQuery = GenericPasswordQueryable(account: name, service: StoreServiceConstants.serviceName, keyChainPassword: keyChainPassword)
		try keychainStore.storeItem(item: seed, queryable: seedQuery)
	}
}
