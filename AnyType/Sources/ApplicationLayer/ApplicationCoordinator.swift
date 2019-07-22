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
	
	// MARK: - Lifecycle
	
	// MARK: - Public methods
	
	func start() {
		
	}
	
	// MARK: - Private methods
	
	private func selectFirstView() -> some View {
		guard let publicKeyes = UserDefaultsConfig.usersPublicKey else {
			return AuthView()
		}
		
		
	}
}
