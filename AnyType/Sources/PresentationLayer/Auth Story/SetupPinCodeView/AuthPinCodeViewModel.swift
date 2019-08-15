//
//  AuthPinCodeViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 02.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI
import Textile

enum AuthPinCodeViewType {
	case setup
	case verify(publicKey: String)
	
	var pinCodeViewType: PinCodeViewType {
		switch self {
		case .setup:
			return .setup
		case .verify:
			return .verify
		}
	}
}

class AuthPinCodeViewModel: ObservableObject {
	var recoveryPhrase: String?
	
	// TODO: move init to fabric
	let storeService: StoreServiceProtocol = KeychainStoreService()
	let authService: AuthService = TextileService()
	
	var pinCodeViewModel: PinCodeViewModel
	var authPinCodeType: AuthPinCodeViewType
	
	@Published var error: String = "" {
		didSet {
			if !error.isEmpty {
				isShowingError = true
			}
		}
	}
	@Published var isShowingError: Bool = false
	
	// MARK: - Lifecycle
	
	init(authPinCodeViewType: AuthPinCodeViewType) {
		self.authPinCodeType = authPinCodeViewType
		self.pinCodeViewModel = PinCodeViewModel(pinCodeViewType: authPinCodeViewType.pinCodeViewType)
	}
	
	// MARK: - Public methods
	
	func onConfirm() {
		switch authPinCodeType {
		case .setup:
			saveSeedPhrase(password: pinCodeViewModel.pinCode)
		case .verify(let publicKey):
			do {
				let seed = try obtainSeedPhrase(publicKey: publicKey, password: pinCodeViewModel.pinCode)
				try authService.login(with: seed)
				showHomeView()
			} catch {
				self.error = error.localizedDescription
				return
			}
		}
	}
	
	// MARK: - Private methods
	
	private func saveSeedPhrase(password: String) {
		guard let recoveryPhrase = recoveryPhrase else {
			self.error = AuthServiceError.createWalletError(message: "Recovery pharse is nil").localizedDescription
			return
		}
		authService.createWalletAndAccount(with: recoveryPhrase) { [weak self] result in
			if case Result.failure(let error) = result {
				self?.error = error.localizedDescription
			}
		
			let publicKey = Textile.instance().account.address()
			let seed = Textile.instance().account.seed()
			
			do {
				try self?.storeService.saveSeedForAccount(name: publicKey, seed: seed, keyChainPassword: password)
			} catch {
				self?.error = error.localizedDescription
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
