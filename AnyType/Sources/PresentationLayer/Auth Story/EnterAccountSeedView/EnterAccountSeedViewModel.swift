//
//  EnterAccountSeedViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 13.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

class EnterAccountSeedViewModel: ObservableObject {
	private var textileService = TextileAuthService()
	
	@Published var seedPhrase: String = ""
	@Published var seedAccepted: Bool = false
	@Published var error: String = "" {
		didSet {
			if !error.isEmpty {
				isShowingError = true
			}
		}
	}
	@Published var isShowingError: Bool = false
	
	// MARK: - Public methods
	
	func verifySeedPhrase() {
		do {
			try textileService.login(with: seedPhrase)
			showHomeView()
		} catch {
			self.error = error.localizedDescription
		}
	}
	
	// MARK: - Private methodss
	
	private func showHomeView() {
		let view = HomeView()
		applicationCoordinator?.startNewRootView(content: view)
	}
}
