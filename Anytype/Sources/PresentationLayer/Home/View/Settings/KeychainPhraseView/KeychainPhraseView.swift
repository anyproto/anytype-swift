import SwiftUI


struct KeychainPhraseView: View {
    var shownInContext: AnalyticsEventsKeychainContext

    @StateObject private var model = KeychainPhraseViewModel()
    @State private var toastBarData: ToastBarData = .empty
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DragIndicator()
            Spacer.fixedHeight(24)
            AnytypeText(Loc.backUpYourRecoveryPhrase, style: .heading, color: .Text.primary)
            Spacer.fixedHeight(8)
            AnytypeText(Loc.Keychain.recoveryPhraseDescription, style: .uxBodyRegular, color: .Text.primary)
            Spacer.fixedHeight(24)
            SeedPhraseView(model: model) {
                didShowPhrase()
            }
            Spacer()
            StandardButton(text: Loc.Keychain.showAndCopyPhrase, style: .secondary) {
                model.onSeedViewTap(onTap: {
                    didShowPhrase()
                })
            }
            Spacer.fixedHeight(20)
        }
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .onAppear {
            AnytypeAnalytics.instance().logKeychainPhraseShow(shownInContext)
        }
        .snackbar(toastBarData: $toastBarData)
        .environmentObject(model)
    }
    
    private func didShowPhrase() {
        toastBarData = .init(text: Loc.Keychain.recoveryPhraseCopiedToClipboard, showSnackBar: true)
        AnytypeAnalytics.instance().logKeychainPhraseCopy(shownInContext)
    }
}

struct SaveRecoveryPhraseView_Previews: PreviewProvider {    
    static var previews: some View {
        return KeychainPhraseView(shownInContext: .settings)
    }
}
