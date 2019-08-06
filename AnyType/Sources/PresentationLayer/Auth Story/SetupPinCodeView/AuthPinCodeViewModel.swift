//
//  AuthPinCodeViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 02.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI
import Textile

class AuthPinCodeViewModel: ObservableObject {
	var storeService: StoreServiceProtocol?
	var authService: AuthService?
	
	var pinCodeViewModel: PinCodeViewModel
	
	@Published var storeError: Error? = nil
	@Published var keyChainError: Error? = nil
	@Published var pinAccepted: Bool = false
	
	// MARK: - Lifecycle
	
	init(pinCodeViewType: PinCodeViewType) {
		self.pinCodeViewModel = PinCodeViewModel(pinCodeViewType: pinCodeViewType)
	}
	
	// MARK: - Public methods
	
	func onConfirm() {
		switch pinCodeViewModel.pinCodeViewType {
		case .setup:
			saveSeedPhrase(password: pinCodeViewModel.pinCode)
		case .verify(let publicAddress):
			if let seed = obtainSeedPhrase(publicKey: publicAddress, password: pinCodeViewModel.pinCode) {
				do {
					try authService?.login(with: seed)
				} catch {
					keyChainError = error as? Error
					return
				}
			}
		}
		pinAccepted = true
	}
	
	// MARK: - Private methods
	
	private func saveSeedPhrase(password: String) {
		let publicKey = Textile.instance().account.address()
		let seed = Textile.instance().account.seed()
		
		do {
			try storeService?.saveSeedForAccount(name: publicKey, seed: seed, keyChainPassword: password)
		} catch {
			self.storeError = error as? Error
		}
	}
	
	private func obtainSeedPhrase(publicKey: String, password: String) -> String? {
		do {
			let seed = try storeService?.obtainSeed(for: publicKey, keyChainPassword: password)
			return seed
		} catch {
			self.storeError = error as? Error
			return nil
		}
	}
	
}
