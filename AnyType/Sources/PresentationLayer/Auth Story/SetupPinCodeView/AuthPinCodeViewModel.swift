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
	var recoveryPhrase: String?
	
	// TODO: move init to fabric
	let storeService: StoreServiceProtocol = KeychainStoreService()
	let authService: AuthService = TextileService()
	
	var pinCodeViewModel: PinCodeViewModel
	
	@Published var error: Error? = nil
	@Published var authError: AuthServiceError? = nil
	@Published var keyChainError: Error? = nil
	
	// MARK: - Lifecycle
	
	init(pinCodeViewType: PinCodeViewType) {
		self.pinCodeViewModel = PinCodeViewModel()
		self.pinCodeViewModel.pinCodeViewType = pinCodeViewType
	}
	
	// MARK: - Public methods
	
	func onConfirm() {
		switch pinCodeViewModel.pinCodeViewType {
		case .setup:
			saveSeedPhrase(password: pinCodeViewModel.pinCode)
		case .verify(let publicAddress):
			do {
				let seed = try obtainSeedPhrase(publicKey: publicAddress, password: pinCodeViewModel.pinCode)
				try authService.login(with: seed)
				showHomeView()
			} catch {
				keyChainError = error as? Error
				return
			}
		}
	}
	
	// MARK: - Private methods
	
	private func saveSeedPhrase(password: String) {
		guard let recoveryPhrase = recoveryPhrase else {
			self.authError = AuthServiceError.createWalletError(message: "Recovery pharse is nil")
			return
		}
		authService.createWalletAndAccount(with: recoveryPhrase) { [weak self] result in
			if case Result.failure(let error) = result {
				self?.authError = error
			}
		
			let publicKey = Textile.instance().account.address()
			let seed = Textile.instance().account.seed()
			
			do {
				try self?.storeService.saveSeedForAccount(name: publicKey, seed: seed, keyChainPassword: password)
			} catch {
				self?.error = error as? Error
			}
			self?.showHomeView()
		}
	}
	
	private func obtainSeedPhrase(publicKey: String, password: String) throws -> String {
		let seed = try storeService.obtainSeed(for: publicKey, keyChainPassword: password)
		
		return seed
	}
	
	private func showHomeView() {
		let view = HomeView()
		applicationCoordinator?.startNewRootView(content: view)
	}
	
}
