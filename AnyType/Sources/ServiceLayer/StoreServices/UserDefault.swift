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

/// User defaults store
struct UserDefaultsConfig {
	static let removePublicKeysSubject = PassthroughSubject<[String], Never>()
	private static let keyChainStore = KeychainStoreService()
	
    @UserDefault("usersPublicKey", defaultValue: [])
	static var usersPublicKey: [String]
	
	@UserDefault("notificationUpdates", defaultValue: false)
	static var notificationUpdates: Bool
	
	@UserDefault("notificationNewInvites", defaultValue: false)
	static var notificationNewInvites: Bool
	
	@UserDefault("notificationNewComments", defaultValue: false)
	static var notificationNewComments: Bool
	
	@UserDefault("notificationNewDevice", defaultValue: false)
	static var notificationNewDevice: Bool
}
