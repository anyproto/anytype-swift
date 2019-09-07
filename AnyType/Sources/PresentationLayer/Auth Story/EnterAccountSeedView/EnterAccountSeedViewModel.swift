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
	
	@Published var recoveryPhrase: String = ""
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
		textileService.login(recoveryPhrase: recoveryPhrase) { [weak self] error in
			if let error = error {
				self?.error = error.localizedDescription
				return
			}
			self?.showHomeView()
		}
	}
	
	// MARK: - Private methodss
	
	private func showHomeView() {
		let view = HomeViewContainer()
		applicationCoordinator?.startNewRootView(content: view)
	}
}
