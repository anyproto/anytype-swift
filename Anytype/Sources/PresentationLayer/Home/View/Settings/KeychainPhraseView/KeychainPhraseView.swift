import SwiftUI
import Amplitude


struct KeychainPhraseView: View {
    @ObservedObject var viewModel: KeychainPhraseViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DragIndicator()
            
            AnytypeText("Keychain phrase".localized, style: .title, color: .textPrimary)
                .padding(.top, 58)
            AnytypeText("Keychain phrase description".localized, style: .uxBodyRegular, color: .textPrimary)
                .padding(.top, 25)
            SeedPhraseView(phrase: $viewModel.recoveryPhrase, onTap: viewModel.onSeedViewTap)
                .padding(.top, 34)

            Spacer()
        }
        .cornerRadius(12)
        .padding([.leading, .trailing])
        .snackbar(
            isShowing: $viewModel.showSnackbar,
            text: AnytypeText("Keychain phrase copied to clipboard".localized, style: .uxCalloutRegular, color: .textPrimary)
        )
        .onAppear {
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.showKeychainPhraseScreen)

            viewModel.obtainRecoveryPhrase()
        }
    }
}

struct SaveRecoveryPhraseView_Previews: PreviewProvider {
    static let phrase = "stuck a ten on my hand twenty carats slap a bitch your girl choose up imma bag her and i snatch her"
    
    static let viewModel: KeychainPhraseViewModel = {
        let model = KeychainPhraseViewModel()
        model.recoveryPhrase = phrase
        return model
    }()
    
    static var previews: some View {
        return KeychainPhraseView(viewModel: viewModel)
    }
}
