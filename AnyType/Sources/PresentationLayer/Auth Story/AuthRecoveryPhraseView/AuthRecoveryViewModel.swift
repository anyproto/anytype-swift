//
//  AuthRecoveryViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 30.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Combine
import SwiftUI
import Textile

class AuthRecoveryViewModel: ObservableObject {
	var authService: AuthService?
	
	@Published var error: AuthServiceError? = nil
	@Published var saveRecoveryModel = SaveRecoveryModel(recoveryPhrase: "")
	
	// MARK: - Public methods
	
	func createAccount() {
		guard let authService = authService else { return }
		
		do {
			try self.saveRecoveryModel.recoveryPhrase = authService.generateRecoveryPhrase(wordCount: 12)
		} catch {
			self.error = error as? AuthServiceError
		}
	}
	
}
