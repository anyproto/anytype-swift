//
//  SaveRecoveryPhraseViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 30.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Combine
import SwiftUI
import Textile

class SaveRecoveryPhraseViewModel: ObservableObject {
	var authService: AuthService?
	var storeService: KeychainStoreService?
	
	@Published var recoveryPhrase: String  = ""
	@Published var error: AuthServiceError? = nil
	
	// MARK: - Public methods
	
	func createAccount() {
		authService?.createWalletAndAccount { result in
			switch result {
			case .success(let recoveryPhrase):
				self.recoveryPhrase = recoveryPhrase
			case .failure(let error):
				self.error = error
			}
		}
	}
	
}
