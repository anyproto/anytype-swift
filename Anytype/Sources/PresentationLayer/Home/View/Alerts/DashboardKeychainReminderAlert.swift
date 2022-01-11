import SwiftUI
import Amplitude

struct DashboardKeychainReminderAlert: View {
    var shownInContext: AmplitudeEventsKeychainContext
    @EnvironmentObject private var model: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(23)
            AnytypeText("Don’t forget to save your keychain phrase".localized, style: .heading, color: .textPrimary)
            Spacer.fixedHeight(11)
            description
            Spacer.fixedHeight(18)
            SeedPhraseView {
                model.snackBarData = .init(text: "Keychain phrase copied to clipboard", showSnackBar: true)

                Amplitude.instance().logKeychainPhraseCopy(shownInContext)
            }
            Spacer.fixedHeight(25)
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundPrimary)
        .cornerRadius(16)
    }
    
    private var description: some View {
        Text("Save keychain alert part 1".localized)
            .font(AnytypeFontBuilder.font(anytypeFont: .uxCalloutRegular))
        +
        Text("Save keychain alert part 2".localized)
            .font(AnytypeFontBuilder.font(anytypeFont: .uxCalloutMedium))
        +
        Text("Save keychain alert part 3".localized)
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
