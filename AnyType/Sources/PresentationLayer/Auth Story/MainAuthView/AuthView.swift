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
	@EnvironmentObject var applicationState: ApplicationState
	
	init(viewModel: AuthViewModel) {
		self.viewModel = viewModel
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
					if !viewModel.publicKeys.isEmpty {
						Picker(selection: $selectedKey, label: Text("Accounts")) {
							ForEach(0 ..< viewModel.publicKeys.count) {
								Text(self.viewModel.publicKeys[$0]).tag($0)
							}
						}
					}

					Text(viewModel.publicKeys.isEmpty ? "FirstCreateAnAccount" : "or create an account").font(.headline).fontWeight(.regular)
					
					StandardButton(text: "Create new account", style: .black) {
						self.applicationState.currentRootView = .saveRecoveryPhrase
					}

					StandardButton(text: "I have an account", style: .black) {
					}
				}.padding(.top, 20)
			}
			.frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
			.padding(.all, 40)
		}
	}
	
}

#if DEBUG
struct SwiftUIView_Previews : PreviewProvider {
	static var previews: some View {
		let viewModel = AuthViewModel()
		return AuthView(viewModel: viewModel).environmentObject(ApplicationState())
	}
}
#endif
