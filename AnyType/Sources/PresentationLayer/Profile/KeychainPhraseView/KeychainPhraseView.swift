import SwiftUI

struct KeychainPhraseView: View {
    @ObservedObject var viewModel: KeychainPhraseViewModel
    @Binding var showKeychainView: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DragIndicator()
            AnytypeText("Back up your keychain phrase", style: .title)
                .padding(.top, 34)
            AnytypeText("Your Keychain phrase protects your account. You’ll need it to sign in if you don’t have access to your devices. Keep it in a safe place.", style: .body)
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
                .anyTypeFont(.body)
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

struct SaveRecoveryPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        return KeychainPhraseView(viewModel: KeychainPhraseViewModel(), showKeychainView: .constant(true))
    }
}
