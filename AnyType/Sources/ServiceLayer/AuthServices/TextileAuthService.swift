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
	private let nodePublisher = PassthroughSubject<Bool, Never>()
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
		cleanCurrentRepo { [weak self] in
			guard let strongSelf = self else {
				return
			}
			
			var error: NSError?
			// recoveryPhrase should be optional here, fix coming asap
			let recoveryPhrase = Textile.initializeCreatingNewWalletAndAccount(strongSelf.textileRepo, debug: false, logToDisk: false, error: &error)
			// Return phrase to the user for secure, out of app, storage
			print("recoveryPhrase: \(recoveryPhrase)")
			
			if error != nil {
				let error = AuthServiceError.createWalletError(message: error?.localizedDescription)
				onReceivingRecoveryPhrase(.failure(error))
			}
			strongSelf.createNodeSubscriber() { error in
				let result: Result<String, AuthServiceError> = error != nil ? .failure(error!) : .success(recoveryPhrase)
				onReceivingRecoveryPhrase(result)
			}
			
			do {
				try self?.launchTextile()
			} catch {
				let error = AuthServiceError.createWalletError(message: error.localizedDescription)
				onReceivingRecoveryPhrase(.failure(error))
			}
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
		
		cleanCurrentRepo { [weak self] in
			guard let strongSelf = self else {
				return
			}
			
			var error: NSError?
			
			// resolve a wallet account
			let mobileWalletAccount = Textile.walletAccount(at: recoveryPhrase, index: 0, password: "", error: &error)
			
			if mobileWalletAccount.seed == nil, let error = error {
				let error = AuthServiceError.createWalletError(message: error.localizedDescription)
				onReceivingRecoveryPhrase(.failure(error))
			}
			
			do {
				try Textile.initialize(strongSelf.textileRepo, seed: mobileWalletAccount.seed, debug: false, logToDisk: false)
			} catch {
				let error = AuthServiceError.createWalletError(message: error.localizedDescription)
				onReceivingRecoveryPhrase(.failure(error))
			}
			strongSelf.createNodeSubscriber() { error in
				let result: Result<String, AuthServiceError> = error != nil ? .failure(error!) : .success(recoveryPhrase)
				onReceivingRecoveryPhrase(result)
			}
			
			do {
				try self?.launchTextile()
			} catch {
				let error = AuthServiceError.createWalletError(message: error.localizedDescription)
				onReceivingRecoveryPhrase(.failure(error))
			}
		}
	}
	
	func login(seed: String, completion: @escaping (_ : Swift.Error?) -> Void) {
		cleanCurrentRepo { [weak self] in
			guard let strongSelf = self else { return }
			
			do {
				try Textile.initialize(strongSelf.textileRepo, seed: seed, debug: false, logToDisk: false)
				strongSelf.createNodeSubscriber(completion: completion)
				try strongSelf.launchTextile()
			} catch {
				completion(error)
			}
		}
	}
	
	func login(recoveryPhrase: String, completion: @escaping (_ : Swift.Error?) -> Void) {
		createWalletAndAccount(with: recoveryPhrase) { result in
			if case Result.failure(let error) = result {
				completion(error)
				return
			}
			completion(nil)
		}
	}
	
	func logout(completion: @escaping () -> Void) {
		cleanCurrentRepo {
			completion()
		}
	}
	
	func removeAccount(publicKey: String) throws {
		UserDefaultsConfig.usersPublicKey.removeAll {
			$0 == publicKey
		}
		
		try? keyChainStore.removeSeed(for: publicKey)
	}
	
	private func cleanCurrentRepo(completion: @escaping () -> Void) {
		if Textile.isInitialized(textileRepo) {
			Textile.instance().destroy { isSuccess, error in
				try? FileManager.default.removeItem(atPath: self.textileRepo)
				
				DispatchQueue.main.async {
					completion()
				}
			}
		} else {
			try? FileManager.default.removeItem(atPath: self.textileRepo)
			completion()
		}
	}
	
	private func createNodeSubscriber(completion: ((_ : AuthServiceError?) -> Void)?) {
		nodeSubscriber = nodePublisher.sink(receiveValue: { [weak self] value in
			defer {
				self?.nodeSubscriber?.cancel()
			}
			guard value == true else {
				let error =  AuthServiceError.loginError(message: "node failed to start")
				completion?(error)
				return
			}
			let publicKey = Textile.instance().account.address()
			UserDefaultsConfig.usersPublicKey.appendUniq(publicKey)
			completion?(nil)
		})
	}
}

extension TextileAuthService: TextileDelegate {
	
	func nodeStarted() {
		print("node started")
		
		self.nodePublisher.send(true)
	}
	
	func nodeFailedToStartWithError(_ error: Error) {
		print("node failed to start")
		
		self.nodePublisher.send(false)
	}
}
