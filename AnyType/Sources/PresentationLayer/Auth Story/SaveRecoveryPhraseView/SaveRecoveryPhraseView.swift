//
//  SaveRecoveryPhraseView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 30.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct SaveRecoveryPhraseView: View {
	@ObservedObject var viewModel: SaveRecoveryPhraseViewModel
	@EnvironmentObject var applicationState: ApplicationState
	
    var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("Here's your recovery phrase")
				.font(.title).fontWeight(.bold)
			Text("Please make sure to keep and back up your recovery phrases").font(.body).fontWeight(.medium).lineLimit(nil).padding(.top)
			Text(viewModel.recoveryPhrase)
				.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
				.padding()
				.background(Color("backgroundColor"))
				.padding(.top)
				.cornerRadius(7)
				.font(.robotMonoRegularFontWith(size: 15.0))
				.lineLimit(nil)
			StandardButton(text: "I've written it down", style: .yellow) {
				self.applicationState.currentRootView = .pinCode(state: .setup)
			}.padding()
			Spacer()
		}
		.padding()
		.padding(.top, 40)
		.onAppear(perform: createRecoveryPhrase)
	}
	
	private func createRecoveryPhrase() {
		viewModel.createAccount()
	}
}

#if DEBUG
struct SaveRecoveryPhraseView_Previews: PreviewProvider {
    static var previews: some View {
		let viewModel = SaveRecoveryPhraseViewModel()
		viewModel.recoveryPhrase = "some phrase to save"
        return SaveRecoveryPhraseView(viewModel: viewModel)
    }
}
#endif
