//
//  SaveRecoveryPhraseView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 30.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct SaveRecoveryModel {
	var recoveryPhraseSaved: Bool = false
	var recoveryPhrase: String
}

struct SaveRecoveryPhraseView: View {
	@Binding var model: SaveRecoveryModel
	
    var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			
			Text("Here's your recovery phrase")
				.font(.title).fontWeight(.bold)
			Text("Please make sure to keep and back up your recovery phrases").font(.body).fontWeight(.medium).lineLimit(nil).padding(.top)
			Text(model.recoveryPhrase)
				.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
				.padding()
				.background(Color("backgroundColor"))
				.cornerRadius(7)
				.font(.robotMonoRegularFontWith(size: 15.0))
			StandardButton(disabled: false, text: "I've written it down", style: .yellow) {
				self.model.recoveryPhraseSaved = true
			}.padding()
		}
	}
}

#if DEBUG
struct SaveRecoveryPhraseView_Previews: PreviewProvider {
    static var previews: some View {
		let model = SaveRecoveryModel(recoveryPhrase: "some phrase to save")
		return SaveRecoveryPhraseView(model: .constant(model))
    }
}
#endif
