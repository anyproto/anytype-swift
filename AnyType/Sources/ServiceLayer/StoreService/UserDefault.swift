//
//  UserDefault.swift
//  AnyType
//
//  Created by Denis Batvinkin on 21.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import Combine

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

	var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

struct UserDefaultsConfig {
	static let removePublicKeysSubject = PassthroughSubject<[String], Never>()
	private static let keyChainStore = KeychainStoreService()
	
    @UserDefault("usersPublicKey", defaultValue: [])
	static var usersPublicKey: [String] {
		didSet {
			let usersPublicKeyRemoved = Array(Set(oldValue).subtracting(Set(usersPublicKey)))
			
			for key in usersPublicKeyRemoved {
				try? keyChainStore.removeSeed(for: key)
			}
		}
	}
}
