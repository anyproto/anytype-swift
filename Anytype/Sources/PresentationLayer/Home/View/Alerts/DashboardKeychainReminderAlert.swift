import SwiftUI

struct DashboardKeychainReminderAlert: View {
    var shownInContext: AnalyticsEventsKeychainContext
    @EnvironmentObject private var model: HomeViewModel
    @StateObject private var keychainModel = KeychainPhraseViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(23)
            AnytypeText(Loc.Keychain.donTForgetToSaveYourRecoveryPhrase, style: .heading, color: .Text.primary)
            Spacer.fixedHeight(11)
            description
            Spacer.fixedHeight(18)
            SeedPhraseView(model: keychainModel) {
                model.snackBarData = .init(text: Loc.Keychain.recoveryPhraseCopiedToClipboard, showSnackBar: true)

                AnytypeAnalytics.instance().logKeychainPhraseCopy(shownInContext)
            }
            Spacer.fixedHeight(25)
        }
        .padding(.horizontal, 20)
        .background(Color.Background.primary)
        .cornerRadius(16)
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
            DashboardKeychainReminderAlert(shownInContext: .signup)
        }
    }
}
