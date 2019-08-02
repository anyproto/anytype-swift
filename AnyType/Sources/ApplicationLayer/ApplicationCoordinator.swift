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

enum CurrentRootView {
	case auth(publicKeys: [String]? = nil)
	case saveRecoveryPhrase
	case setPinCode
	case home
}

class ApplicationState: ObservableObject {
	@Published var isLoggedIn: Bool = false
	@Published var currentRootView: CurrentRootView = .auth(publicKeys: nil)
	
	// MARK: - Lifecycle
	
	init() {
		checkAccountInKeychain()
	}
	
	// MARK: - Private methods
	
	private func checkAccountInKeychain() {
		let publicKeyes = UserDefaultsConfig.usersPublicKey
		
		if publicKeyes.count == 0 {
			self.currentRootView = .auth(publicKeys: nil)
		} else if publicKeyes.count == 1 {
			self.currentRootView = .home
		} else {
			self.currentRootView = .auth(publicKeys: publicKeyes)
		}
	}
	
}

/// First coordinator that start ui flow
class ApplicationCoordinator {
	var applicationState = ApplicationState()
	
	// MARK: - Public methods
	
	func start(windowScene: UIWindowScene) -> UIWindow {
		let window = UIWindow(windowScene: windowScene)
		window.rootViewController = UIHostingController(rootView: StartView().environmentObject(applicationState))
		
		return window
	}
	
}
