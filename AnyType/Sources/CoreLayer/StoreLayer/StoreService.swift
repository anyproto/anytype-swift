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

/// Protocol for interaction with store
protocol StoreServiceProtocol {
	func obtainSeed(for name: String) throws -> String?
	func saveSeedForAccount(name: String) throws
}

/// Keychain store serivce
class KeychainStoreService {
    static let shared = KeychainStoreService()
	
	private let keychainStore = KeychainStore()
	
}


// MARK: - StoreServiceProtocol

extension KeychainStoreService: StoreServiceProtocol {
	
	func obtainSeed(for name: String) throws -> String? {
		let seedQuery = GenericPasswordQueryable(account: name, service: StoreServiceConstants.serviceName)
		let seed = try keychainStore.retreiveItem(queryable: seedQuery)
		
		return seed
	}
	
	func saveSeedForAccount(name: String) throws {
		let seedQuery = GenericPasswordQueryable(account: name, service: StoreServiceConstants.serviceName)
		try keychainStore.storeItem(item: name, queryable: seedQuery)
	}
	
}
