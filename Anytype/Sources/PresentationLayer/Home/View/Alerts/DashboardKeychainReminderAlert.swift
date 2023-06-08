import SwiftUI

struct DashboardKeychainReminderAlert: View {
    @ObservedObject var keychainViewModel: KeychainPhraseViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(23)
            AnytypeText(Loc.Keychain.donTForgetToSaveYourRecoveryPhrase, style: .heading, color: .Text.primary)
            Spacer.fixedHeight(11)
            description
            Spacer.fixedHeight(18)
            SeedPhraseView(model: keychainViewModel)
            Spacer.fixedHeight(25)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 20)
        .background(Color.Background.primary)
        .cornerRadius(16)
        .snackbar(toastBarData: $keychainViewModel.toastBarData)
    }
    
    private var description: some View {
        Text(Loc.Keychain.saveKeychainAlertPart1)
            .font(AnytypeFontBuilder.font(anytypeFont: .uxCalloutRegular))
        +
        Text(Loc.Keychain.saveKeychainAlertPart2)
            .font(AnytypeFontBuilder.font(anytypeFont: .uxCalloutMedium))
        +
        Text(Loc.Keychain.saveKeychainAlertPart3)
            .font(AnytypeFontBuilder.font(anytypeFont: .uxCalloutRegular))
    }
}

struct DashboardKeychainReminderAlert_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            DashboardKeychainReminderAlert(keychainViewModel: KeychainPhraseViewModel.makeForPreview())
        }
    }
}
