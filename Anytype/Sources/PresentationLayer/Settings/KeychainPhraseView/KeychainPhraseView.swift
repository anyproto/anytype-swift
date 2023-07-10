import SwiftUI

struct KeychainPhraseView: View {

    @ObservedObject var model: KeychainPhraseViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DragIndicator()
            Spacer.fixedHeight(24)
            AnytypeText(Loc.backUpYourRecoveryPhrase, style: .heading, color: .Text.primary)
            Spacer.fixedHeight(8)
            AnytypeText(Loc.Keychain.recoveryPhraseDescription, style: .uxBodyRegular, color: .Text.primary)
            Spacer.fixedHeight(24)
            SeedPhraseView(model: model)
            Spacer()
            StandardButton(.text(Loc.Keychain.showAndCopyPhrase), style: .secondaryLarge) {
                model.onSeedViewTap()
            }
            Spacer.fixedHeight(20)
        }
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .onAppear {
            model.onAppear()
        }
        .snackbar(toastBarData: $model.toastBarData)
    }
}

struct SaveRecoveryPhraseView_Previews: PreviewProvider {    
    static var previews: some View {
        return KeychainPhraseView(model: KeychainPhraseViewModel.makeForPreview())
    }
}
