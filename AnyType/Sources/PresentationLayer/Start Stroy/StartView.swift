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
			extractedFunc()
		}
    }
	
	// MARK: - Private methods
	
	fileprivate func extractedFunc() -> AnyView {
		switch applicationState.currentRootView {
		case .auth(let publicKeyes):
			return showAuthView(publicKeys: publicKeyes)
		case .saveRecoveryPhrase:
			return showSaverRecoveryPhraseView()
		case .setPinCode:
			return showPinCodeView()
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
	
	private func showPinCodeView() -> AnyView {
		let view = SetupPinCodeView()
		
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
