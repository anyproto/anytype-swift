import SwiftUI

struct DashboardKeychainReminderAlert: View {
    var shownInContext: AnalyticsEventsKeychainContext
    @EnvironmentObject private var model: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(23)
            AnytypeText(Loc.donTForgetToSaveYourRecoveryPhrase, style: .heading, color: .textPrimary)
            Spacer.fixedHeight(11)
            description
            Spacer.fixedHeight(18)
            SeedPhraseView {
                model.snackBarData = .init(text: Loc.recoveryPhraseCopiedToClipboard, showSnackBar: true)

                AnytypeAnalytics.instance().logKeychainPhraseCopy(shownInContext)
            }
            Spacer.fixedHeight(25)
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundPrimary)
        .cornerRadius(16)
    }
    
    private var description: some View {
        Text(Loc.saveKeychainAlertPart1)
            .font(AnytypeFontBuilder.font(anytypeFont: .uxCalloutRegular))
        +
        Text(Loc.saveKeychainAlertPart2)
            .font(AnytypeFontBuilder.font(anytypeFont: .uxCalloutMedium))
        +
        Text(Loc.saveKeychainAlertPart3)
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
