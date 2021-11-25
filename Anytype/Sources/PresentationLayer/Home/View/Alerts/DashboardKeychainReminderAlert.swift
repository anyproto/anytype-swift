import SwiftUI

struct DashboardKeychainReminderAlert: View {
    @EnvironmentObject private var model: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(23)
            AnytypeText("Don’t forget to save your keychain phrase".localized, style: .heading, color: .textPrimary)
            Spacer.fixedHeight(11)
            AnytypeText("You can always find the phrase in the settings.".localized, style: .uxCalloutRegular, color: .textPrimary)
            Spacer.fixedHeight(18)
            SeedPhraseView {
                model.snackBarData = .init(text: "Keychain phrase copied to clipboard", showSnackBar: true)
            }
            Spacer.fixedHeight(25)
        }
        .padding(.horizontal, 20)
        .background(Color.background)
        .cornerRadius(16)
    }
}

struct DashboardKeychainReminderAlert_Previews: PreviewProvider {
    static var previews: some View {
        DashboardKeychainReminderAlert()
    }
}
