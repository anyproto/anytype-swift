//
//  AuthPinCodeView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 05.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct AuthPinCodeView: View {
    private let defautlNavColor = UINavigationBar.appearance().barTintColor
	private let defautlNavShadow = UINavigationBar.appearance().shadowImage
	
	@ObservedObject var viewModel: AuthPinCodeViewModel
	
    var body: some View {
		VStack {
			PinCodeView(viewModel: $viewModel.pinCodeViewModel, pinCodeConfirmed: {
				self.viewModel.onConfirm()
			})
			
			NavigationLink(destination: showHomeView(), isActive: $viewModel.pinAccepted) {
				EmptyView()
			}
		}
		.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
		.padding()
		.navigationBarTitle("", displayMode: .inline)
		.onDisappear(perform: restoreNavigationApperance)
		
    }
	
	private func showHomeView() -> some View {
		let view = HomeView()
		
		return view
	}
	
	private func restoreNavigationApperance() {
		UINavigationBar.appearance().barTintColor = defautlNavColor
		UINavigationBar.appearance().shadowImage = defautlNavShadow
	}
}

#if DEBUG
struct AuthPinCodeView_Previews: PreviewProvider {
    static var previews: some View {
		let viewModel = AuthPinCodeViewModel(pinCodeViewType: .setup)
		viewModel.storeService = KeychainStoreService()
		viewModel.authService = TextileService()
		
		return AuthPinCodeView(viewModel: viewModel)
    }
}
#endif
