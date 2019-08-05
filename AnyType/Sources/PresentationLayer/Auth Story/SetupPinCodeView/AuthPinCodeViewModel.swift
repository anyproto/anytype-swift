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
	var pinCodeViewModel = PinCodeViewModel()
	
	@Published var storeError: Error? = nil
	@Published var keyChainError: Error? = nil
	
	// MARK: - Lifecycle
	
	init(pinCodeViewType: PinCodeViewType) {
		self.pinCodeViewModel.pinCodeViewType = pinCodeViewType
	}
	
	// MARK: - Public methods
	
	func onConfirm(password: String) {
		switch pinCodeViewModel.pinCodeViewType {
		case .setup:
			saveSeedPhrase(password: password)
		case .verify(let publicAddress):
			if let seed = obtainSeedPhrase(publicKey: publicAddress, password: password) {
				do {
					try authService?.login(with: seed)
				} catch {
					keyChainError = error as? Error
					return
				}
			}
		}
		confirmAction()
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
