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
	
	// MARK: - Public methods
	
	func start(windowScene: UIWindowScene) -> UIWindow {
		let window = UIWindow(windowScene: windowScene)
		
		let publicKeys = UserDefaultsConfig.usersPublicKey
		let authViewCoordinator = AuthViewCoordinator()
		let view = authViewCoordinator.start(publicKeys: publicKeys)
		
		window.rootViewController = UIHostingController(rootView: view)
		
		return window
	}
	
}
