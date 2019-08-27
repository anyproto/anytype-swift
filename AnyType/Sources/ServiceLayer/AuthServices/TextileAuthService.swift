//
//  TextileAuthService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 22.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Textile
import Combine

final class TextileAuthService: NSObject {
	private let subject = PassthroughSubject<Bool, Never>()
	private var textileRepo: String
	private var keyChainStore = KeychainStoreService()
	
	var nodeSubscriber: AnyCancellable?
	
	
	override init() {
		textileRepo = getDocumentsDirectory().appendingPathComponent("textile-go").path
		
		super.init()
	}
	
	// MARK: - Private methods
	
	func launchTextile() throws {
		// Set the Textile delegate to self so we can make use of events such nodeStarted
		
		try Textile.launch(textileRepo, debug: false)
		Textile.instance().delegate = self
	}
}


// MARK: - AuthService protocol

extension TextileAuthService: AuthServiceProtocol {
	
	func createWalletAndAccount(onReceivingRecoveryPhrase: @escaping OnReceivingRecoveryPhrase) {
		// first destroy old account with repo (reset current Textile node)
		do {
			try cleanCurrentRepo()
		} catch {
			let error = AuthServiceError.createWalletError(message: error.localizedDescription)
			onReceivingRecoveryPhrase(.failure(error))
		}
		
		var error: NSError?
		// recoveryPhrase should be optional here, fix coming asap
		let recoveryPhrase = Textile.initializeCreatingNewWalletAndAccount(textileRepo, debug: false, logToDisk: false, error: &error)
		// Return phrase to the user for secure, out of app, storage
		print("recoveryPhrase: \(recoveryPhrase)")
		
		if error != nil {
			let error = AuthServiceError.createWalletError(message: error?.localizedDescription)
			onReceivingRecoveryPhrase(.failure(error))
		}
		
		do {
			try launchTextile()
		} catch {
			let error = AuthServiceError.createWalletError(message: error.localizedDescription)
			onReceivingRecoveryPhrase(.failure(error))
		}
		
		nodeSubscriber = subject.sink { value in
			guard value == true else {
				onReceivingRecoveryPhrase(.failure(.createWalletError(message: "node failed to start")))
				return
			}
			let publicKey = Textile.instance().account.address()
			UserDefaultsConfig.usersPublicKey.append(publicKey)
			onReceivingRecoveryPhrase(.success(recoveryPhrase))
		}
	}
	
	func generateRecoveryPhrase(wordCount: Int?) throws -> String {
		var error: NSError?
		let recoveryPhrase = Textile.newWallet(wordCount ?? 12, error: &error)
		
		if recoveryPhrase.isEmpty, let error = error {
			throw AuthServiceError.generateRecoveryPhraseError(message: error.localizedDescription)
		}
		return recoveryPhrase
	}
	
	func createWalletAndAccount(with recoveryPhrase: String, onReceivingRecoveryPhrase: @escaping OnReceivingRecoveryPhrase) {
		// first destroy old account with repo (reset current Textile node)
		do {
			try cleanCurrentRepo()
		} catch {
			let error = AuthServiceError.createWalletError(message: error.localizedDescription)
			onReceivingRecoveryPhrase(.failure(error))
		}
		var error: NSError?
		
		// resolve a wallet account
		let mobileWalletAccount = Textile.walletAccount(at: recoveryPhrase, index: 0, password: "", error: &error)

		if mobileWalletAccount.seed == nil, let error = error {
			let error = AuthServiceError.createWalletError(message: error.localizedDescription)
			onReceivingRecoveryPhrase(.failure(error))
		}
		
		do {
			try Textile.initialize(textileRepo, seed: mobileWalletAccount.seed, debug: false, logToDisk: false)
		} catch {
			let error = AuthServiceError.createWalletError(message: error.localizedDescription)
			onReceivingRecoveryPhrase(.failure(error))
		}
		
		do {
			try launchTextile()
		} catch {
			let error = AuthServiceError.createWalletError(message: error.localizedDescription)
			onReceivingRecoveryPhrase(.failure(error))
		}
		
		nodeSubscriber = subject.sink { value in
			guard value == true else {
				onReceivingRecoveryPhrase(.failure(.createWalletError(message: "node failed to start")))
				return
			}
			let publicKey = Textile.instance().account.address()
			UserDefaultsConfig.usersPublicKey.append(publicKey)
			onReceivingRecoveryPhrase(.success(recoveryPhrase))
		}
	}
	
	func login(with seed: String) throws {
		do {
			try cleanCurrentRepo()
			try Textile.initialize(textileRepo, seed: seed, debug: false, logToDisk: false)
			try launchTextile()
			
			let publicKey = Textile.instance().account.address()
			UserDefaultsConfig.usersPublicKey.append(publicKey)
		} catch {
			let error = AuthServiceError.logoutError(message: error.localizedDescription)
			throw error
		}
	}
	
	func logout() throws {
		do {
			try cleanCurrentRepo()
		} catch {
			let error = AuthServiceError.logoutError(message: error.localizedDescription)
			throw error
		}
	}
	
	func removeAccount(publicKey: String) throws {
		UserDefaultsConfig.usersPublicKey.removeAll {
			$0 == publicKey
		}
		
		try? keyChainStore.removeSeed(for: publicKey)
	}
	
	private func cleanCurrentRepo() throws {
		if Textile.isInitialized(textileRepo) {
			Textile.instance().destroy()
		}
		try? FileManager.default.removeItem(atPath: textileRepo)
	}
}

extension TextileAuthService: TextileDelegate {
	
	func nodeStarted() {
		self.subject.send(true)
	}
	
	func nodeFailedToStartWithError(_ error: Error) {
		self.subject.send(false)
	}
}
