//
//  SetupPinCodeViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 02.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI
import Textile

class SetupPinCodeViewModel: ObservableObject {
	var storeService: StoreServiceProtocol?
	
	@Published var storeError: Error? = nil
	
	// MARK: - Public methods
	
	func saveSeedPhrase() {
		let publicKey = Textile.instance().account.address()
		
		do {
			try storeService?.saveSeedForAccount(name: publicKey, password: "")
		} catch {
			self.storeError = error as? Error
		}
	}
	
}
