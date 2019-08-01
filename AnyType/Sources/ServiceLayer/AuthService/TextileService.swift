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
		textileRepo = getDocumentsDirectory().appendingPathComponent("textile-go").absoluteString
		
		super.init()
		
		// Set the Textile delegate to self so we can make use of events such nodeStarted
		Textile.instance().delegate = self
	}
	
	// MARK: - Private methods
	
	private func launchTextile() throws {
		try Textile.launch(textileRepo, debug: false)
	}
}


// MARK: - AuthService protocol

extension TextileService: AuthService {
	
	func createWalletAndAccount() throws -> String {
			var error: NSError?
			// recoveryPhrase should be optional here, fix coming asap
			let recoveryPhrase = Textile.initializeCreatingNewWalletAndAccount(textileRepo, debug: false, logToDisk: false, error: &error)
			// Return phrase to the user for secure, out of app, storage
			print("recoveryPhrase: \(recoveryPhrase)")
			
			if error != nil {
				throw AuthServiceError.createWalletError(message: error?.localizedDescription)
			}
			
			do {
				try launchTextile()
			} catch {
				throw AuthServiceError.createWalletError(message: error.localizedDescription)
			}
			
			return recoveryPhrase
		}
		
		func login(with seed: String) throws {
			if !Textile.isInitialized(textileRepo) {
				do {
					try Textile.initialize(textileRepo, seed: seed, debug: false, logToDisk: false)
					try launchTextile()
				} catch {
					throw AuthServiceError.logoutError(message: error.localizedDescription)
				}
			}
		}
		
		func logout() throws {
			if Textile.isInitialized(textileRepo) {
				var error: NSError?
				textile?.destroy(&error)
				
				if error != nil {
					throw AuthServiceError.logoutError(message: error?.localizedDescription)
				}
			}
		}
}

extension TextileService: TextileDelegate {
}
