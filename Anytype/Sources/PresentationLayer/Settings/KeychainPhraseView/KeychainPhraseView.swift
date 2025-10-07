import SwiftUI

struct KeychainPhraseView: View {

    @StateObject private var model: KeychainPhraseViewModel
    
    init(context: AnalyticsEventsKeychainContext) {
        _model = StateObject(wrappedValue: KeychainPhraseViewModel(shownInContext: context))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DragIndicator()
            Spacer.fixedHeight(24)
            TitleView(title: Loc.loginKey)
            Spacer.fixedHeight(8)
            AnytypeText(Loc.Keychain.Key.description, style: .uxBodyRegular)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(24)
            SeedPhraseView(model: model)
            Spacer()
            StandardButton(Loc.Keychain.showAndCopyKey, style: .secondaryLarge) {
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
        .anytypeSheet(item: $model.secureAlertData) {
            SecureAlertView(data: $0)
        }
    }
}

struct SaveRecoveryPhraseView_Previews: PreviewProvider {    
    static var previews: some View {
        return KeychainPhraseView(context: .logout)
    }
}
