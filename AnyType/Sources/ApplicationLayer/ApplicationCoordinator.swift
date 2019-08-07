//
//  ApplicationCoordinator.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

/// First coordinator that start ui flow
class ApplicationCoordinator {
	private let window: UIWindow
	private let keychainStore = KeychainStoreService()
	
	// MARK: - Lifecycle
	
	init(window: UIWindow) {
		self.window = window
	}
	
	// MARK: - Public methods
	
	func start() {
		// just in case
		removePublicKeysIfSeedsNotExist(publicKeys: UserDefaultsConfig.usersPublicKey)
		
		let publicKeys = UserDefaultsConfig.usersPublicKey
		let authViewCoordinator = AuthViewCoordinator()
		let view = authViewCoordinator.start(publicKeys: publicKeys)
		
		startNewRootView(content: view)
	}
	
	func startNewRootView<Content: View>(content: Content) {
		window.rootViewController = UIHostingController(rootView: content)
		window.makeKeyAndVisible()
	}
	
	private func removePublicKeysIfSeedsNotExist(publicKeys: [String]) {
		for key in publicKeys {
			removePublicKeyIfSeedNotExists(publicKey: key)
		}
	}
	
	private func removePublicKeyIfSeedNotExists(publicKey: String) {
		if !keychainStore.containsSeed(for: publicKey) {
			UserDefaultsConfig.usersPublicKey = UserDefaultsConfig.usersPublicKey.filter {
				$0 != publicKey
			}
		}
	}
	
}
