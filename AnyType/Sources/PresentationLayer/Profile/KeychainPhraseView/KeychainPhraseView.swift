//
//  SaveRecoveryPhraseView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 30.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct KeychainPhraseView: View {
    @ObservedObject var viewModel: KeychainPhraseViewModel
    @Binding var showKeychainView: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Rectangle()
                    .cornerRadius(6)
                    .frame(width: 48, height: 5)
                    .foregroundColor(Color("DividerColor"))
                Spacer()
            }
            .padding(.top, 6)
            Text("Back up your keychain phrase")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 34)
            Text("Your Keychain phrase protects your account. You’ll need it to sign in if you don’t have access to your devices. Keep it in a safe place.")
                .font(.body)
                .fontWeight(.medium)
                .padding(.top, 25)
            SeedPhraseView(phrase: $viewModel.recoveryPhrase, copySeedAction: $viewModel.copySeedAction)
                .padding(.top, 34)
                .layoutPriority(1) // TODO: remove workaround when fixed by apple

            StandardButton(disabled: false ,text: "I've written it down", style: .yellow) {
                self.showKeychainView = false
            }
            .padding(.top, 40)
            Spacer()
        }
        .cornerRadius(12)
        .padding([.leading, .trailing], 20)
        .onAppear() {
            self.viewModel.viewLoaded()
        }
    }
}

struct SeedPhraseView: View {
    @Binding var phrase: String
    @Binding var copySeedAction: Void

    var body: some View {
        VStack(alignment: .center) {
            Text(phrase)
                .font(.robotMonoRegular(15.0))
                .padding([.leading, .trailing], 20)
                .padding([.top, .bottom], 12)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color("backgroundColor"))
        .cornerRadius(8)
        .contextMenu {
            Button(action: {
                self.copySeedAction = ()
            }) {
                Text("Copy")
                Image(systemName: "doc.on.doc")
            }
        }
    }
}

#if DEBUG
struct SaveRecoveryPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        return KeychainPhraseView(viewModel: KeychainPhraseViewModel(), showKeychainView: .constant(true))
    }
}
#endif
