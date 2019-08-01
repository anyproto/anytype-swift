//
//  ApplicationCoordinator.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import UIKit
import SwiftUI

/// First coordinator that start ui flow
class ApplicationCoordinator {
	
	/// How many user accounts we have stored on device
	enum AccountsCount {
		case empty
		case one(publicKey: String)
		case many(publicKeys: [String])
		
		init(publicKeyes: [String]) {
			switch publicKeyes.count {
			case 1:
				guard let key = publicKeyes.first else {
					fallthrough
				}
				self = .one(publicKey: key)
			case 2...Int.max:
				self = .many(publicKeys: publicKeyes)
			default:
				self = .empty
			}
		}
	}
	
	// MARK: - Lifecycle
	
	// MARK: - Public methods
	
	func start(windowScene: UIWindowScene) -> UIWindow {
		let window = UIWindow(windowScene: windowScene)
		let view = selectFirstView()
		window.rootViewController = UIHostingController(rootView: view)
		
		return window
	}
	
	// MARK: - Private methods
	
	private func selectFirstView() -> some View {
		let publicKeyes = UserDefaultsConfig.usersPublicKey
		let accontsCount = AccountsCount(publicKeyes: publicKeyes)
		
		switch accontsCount {
		case .empty:
			return AnyView(AuthViewCoordinator().start())
		case .one(let publicKey):
			return AnyView(HomeViewCoordinator().start())
		case .many(let publicKeys):
			return AnyView(AuthViewCoordinator().start(publicKeys: publicKeys))
		}
	}
	
}
