//
//  TextileService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 22.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import Textile

class TextileService: NSObject {
	private var textileRepo: String
	private var textile: Textile?
	
	override init() {
		textileRepo = getDocumentsDirectory().appendingPathComponent("textile-go").path
		
		super.init()
		
		// Set the Textile delegate to self so we can make use of events such nodeStarted
		Textile.instance().delegate = self
	}
	
	// MARK: - Private methods
	
	fileprivate func launchTextile() throws {
		try Textile.launch(textileRepo, debug: false)
	}
}


// MARK: - AuthService protocol

extension TextileService: AuthService {
	
	func createWalletAndAccount(onReceivingRecoveryPhrase: OnReceivingRecoveryPhrase) {
		// first destroy old account with repo (reset current Textile node)
		do {
			try destroyAccount()
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
		onReceivingRecoveryPhrase(.success(recoveryPhrase))
	}
	
	func login(with seed: String) throws {
		do {
			try destroyAccount()
			try Textile.initialize(textileRepo, seed: seed, debug: false, logToDisk: false)
			try launchTextile()
		} catch {
			let error = AuthServiceError.logoutError(message: error.localizedDescription)
			throw error
		}
	}
	
	func logout() throws {
		do {
			try destroyAccount()
		} catch {
			let error = AuthServiceError.logoutError(message: error.localizedDescription)
			throw error
		}
	}
	
	fileprivate func destroyAccount() throws {
		if Textile.isInitialized(textileRepo) {
			var error: NSError?
			textile?.destroy(&error)
			
			if error != nil {
				throw AuthServiceError.logoutError(message: error?.localizedDescription)
			}
		}
		try? FileManager.default.removeItem(atPath: textileRepo)
	}
}

extension TextileService: TextileDelegate {
}
