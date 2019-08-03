//
//  StoreService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11/07/2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

private enum StoreServiceConstants {
	static let serviceName = "com.AnyType.seed"
}

// MARK: - StoreServiceProtocol

/// Protocol for interaction with store
protocol StoreServiceProtocol {
	func obtainSeed(for name: String, keyChainPassword: String?) throws -> String
	func saveSeedForAccount(name: String, seed: String, keyChainPassword: String?) throws
}

// MARK: - KeychainStoreService

/// Keychain store serivce
class KeychainStoreService {
    static let shared = KeychainStoreService()
	
	private let keychainStore = KeychainStore()
	
}


// MARK: - StoreServiceProtocol implementaion

extension KeychainStoreService: StoreServiceProtocol {
	
	func obtainSeed(for name: String, keyChainPassword: String? = nil) throws -> String {
		let seedQuery = GenericPasswordQueryable(account: name, service: StoreServiceConstants.serviceName, keyChainPassword: keyChainPassword)
		let seed = try keychainStore.retreiveItem(queryable: seedQuery)
		
		return seed
	}
	
	func saveSeedForAccount(name: String, seed: String, keyChainPassword: String? = nil) throws {
		let seedQuery = GenericPasswordQueryable(account: name, service: StoreServiceConstants.serviceName, password: seed, keyChainPassword: keyChainPassword)
		try keychainStore.storeItem(item: name, queryable: seedQuery)
	}
}
