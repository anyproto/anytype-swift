//
//  AuthView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct AuthView : View {
	@ObservedObject var viewModel: AuthViewModel
	@State var selectedKey = 0
	@State var recovery: Bool = false
	@State var loginWithPK: Bool = false
	
	init(viewModel: AuthViewModel) {
		self.viewModel = viewModel
		
		UINavigationBar.appearance().barTintColor = .white
		UINavigationBar.appearance().shadowImage = UIImage()
	}
	
	var body: some View {
		NavigationView {
			VStack(alignment: .leading, spacing: 20) {
				Image("logo-sign-part-mobile")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 50, height: 50, alignment: .leading)
				
				VStack(alignment: .leading) {
					Text("Welcome to AnyType!")
						.font(.title)
						.fontWeight(.heavy)
						.padding(.top, 20)
					Text("AnyTypeShortDescription").font(.headline).fontWeight(.regular)
				}
				
				VStack(alignment: .leading) {
					if !viewModel.publicKeys.isEmpty {
						DetailedPickerView(title: Text("Select account for public key").font(.headline),
										   content: $viewModel.publicKeys, selected: $selectedKey)
							.padding()
							.background(Color("backgroundColor"))
							.cornerRadius(7.0)
							.padding(.bottom, 20)
						
						NavigationLink(destination: showAuthPineCodeViweOnExistsPublicKey(publicKey: viewModel.publicKeys[selectedKey]), isActive: $loginWithPK) {
							StandardButton(disabled: false, text: "Login with selected public key", style: .black) {
								self.loginWithPK.toggle()
							}
						}.padding(.bottom, 20)
					}
					
					VStack(alignment: .leading, spacing: 7.0) {
						Text(viewModel.publicKeys.isEmpty ? "FirstCreateAnAccount" : "or create an account").font(.headline)
						
						NavigationLink(destination: showSaverRecoveryPhraseView(), isActive: $recovery) {
							StandardButton(disabled: false, text: "Create new account", style: .black) {
								self.recovery.toggle()
							}
						}.padding(.bottom, 20)
					}
					
					VStack(alignment: .leading, spacing: 7.0) {
						Text("I have an account").font(.headline)
						
						NavigationLink(destination: showEnterAccountSeedView(), isActive: $recovery) {
							StandardButton(disabled: false, text: "Enter account seed", style: .black) {
								self.recovery.toggle()
							}
						}.padding(.bottom, 20)
					}
					
				}
			}
			.frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
			.padding(.horizontal, 40)
		}
	}
	
	private func showSaverRecoveryPhraseView() -> some View {
		let viewModel = AuthRecoveryViewModel()
		viewModel.authService = TextileService()
		let view = AuthRecoveryView(viewModel: viewModel)
		
		return view
	}
	
	private func showAuthPineCodeViweOnExistsPublicKey(publicKey: String) -> some View {
		let viewModel = AuthPinCodeViewModel(pinCodeViewType: .verify(publicAddress: publicKey))
		let view = AuthPinCodeView(viewModel: viewModel)
		
		return view
	}
	
	private func showEnterAccountSeedView() -> some View {
		let viewModel = EnterAccountSeedViewModel()
		let view = EnterAccountSeedView(viewModel: viewModel)
		
		return view
	}
}

#if DEBUG
struct SwiftUIView_Previews : PreviewProvider {
	static var previews: some View {
		let viewModel = AuthViewModel()
		viewModel.publicKeys = ["dsfsdfdsfsdfsdfsdfsdfsdf", "222222222222222", "333333333333333"]
		return AuthView(viewModel: viewModel)
	}
}
#endif
