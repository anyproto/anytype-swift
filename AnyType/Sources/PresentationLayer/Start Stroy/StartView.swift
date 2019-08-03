//
//  StartView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 02.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct StartView: View {
	@EnvironmentObject private var applicationState: ApplicationState
	
	var body: some View {
		VStack {
			currentView()
		}
    }
	
	// MARK: - Private methods
	
	fileprivate func currentView() -> AnyView {
		switch applicationState.currentRootView {
		case .auth(let publicKeyes):
			return showAuthView(publicKeys: publicKeyes)
		case .saveRecoveryPhrase:
			return showSaverRecoveryPhraseView()
		case .pinCode(let state):
			return showPinCodeView(state: state)
		case .home:
			return showHomeView()
		}
	}
	
	private func showSaverRecoveryPhraseView() -> AnyView {
		let viewModel = SaveRecoveryPhraseViewModel()
		viewModel.authService = TextileService()
		viewModel.storeService = KeychainStoreService()
		let view = SaveRecoveryPhraseView(viewModel: viewModel)
		
		return AnyView(view)
	}
	
	private func showAuthView(publicKeys: [String]?) -> AnyView {
		let authViewCoordinator = AuthViewCoordinator()
		let view = authViewCoordinator.start(publicKeys: publicKeys)
		
		return AnyView(view)
	}
	
	private func showHomeView() -> AnyView {
		let view = HomeView()
		
		return AnyView(view)
	}
	
	private func showPinCodeView(state: PinCodeViewState) -> AnyView {
		let viewModel = PinCodeViewModel(pinCodeViewState: state) {
			self.applicationState.currentRootView = .home
		}
		viewModel.storeService = KeychainStoreService()
		viewModel.authService = TextileService()
		let view = PinCodeView(viewModel: viewModel)
		
		return AnyView(view)
	}
}

#if DEBUG
struct StartView_Previews: PreviewProvider {
    static var previews: some View {
		StartView().environmentObject(ApplicationState())
    }
}
#endif
