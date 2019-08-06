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
	
	init(viewModel: AuthViewModel) {
		self.viewModel = viewModel
		
		UINavigationBar.appearance().barTintColor = .white
		UINavigationBar.appearance().shadowImage = UIImage()
	}
	
	var body: some View {
		NavigationView {
			VStack(alignment: .leading, spacing: 20) {
				
				Image("logo-sign-part-mobile").resizable().aspectRatio(contentMode: .fit).frame(width: 50, height: 50, alignment: .leading)
				
				VStack(alignment: .leading) {
					Text("Welcome to AnyType!")
						.font(.title)
						.fontWeight(.heavy)
						.padding(.top, 20)
					Text("AnyTypeShortDescription").font(.headline).fontWeight(.regular)
				}
				
				VStack(alignment: .leading) {
					Text("Accounts")
					if !viewModel.publicKeys.isEmpty {
						Picker(selection: $selectedKey, label: Text("")) {
							ForEach(0 ..< viewModel.publicKeys.count) {
								Text(self.viewModel.publicKeys[$0]).tag($0)
							}
						}
						.padding()
						.frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
						.clipShape(RoundedRectangle(cornerRadius: 7.0))
//						.overlay(RoundedRectangle(cornerRadius: 7.0).stroke())
					}
					
					Text(viewModel.publicKeys.isEmpty ? "FirstCreateAnAccount" : "or create an account").font(.headline).fontWeight(.regular)
					
					NavigationLink(destination: showSaverRecoveryPhraseView(), isActive: $recovery) {
						StandardButton(text: "Create new account", style: .black) {
							self.recovery.toggle()
						}
					}
					
					StandardButton(text: "I have an account", style: .black) {
					}
				}.padding(.top, 20)
			}
			.frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
			.padding(.all, 40)
		}
	}
	
	private func showSaverRecoveryPhraseView() -> some View {
		let viewModel = AuthRecoveryViewModel()
		viewModel.authService = TextileService()
		let view = AuthRecoveryView(viewModel: viewModel)
		
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
