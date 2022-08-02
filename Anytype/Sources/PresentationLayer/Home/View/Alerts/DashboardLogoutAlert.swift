import SwiftUI

struct DashboardLogoutAlert: View {
    @EnvironmentObject var model: SettingsViewModel
    
    @State private var isLogoutInProgress = false
    
    var body: some View {
        FloaterAlertView(
            title: Loc.Keychain.haveYouBackedUpYourRecoveryPhrase,
            description: Loc.Keychain.recoveryPhraseDescription,
            leftButtonData: StandardButtonModel(disabled: isLogoutInProgress, text: Loc.backUpPhrase, style: .secondary) {
                model.keychain = true
                model.loggingOut = false
            },
            rightButtonData: StandardButtonModel(inProgress: isLogoutInProgress, text: Loc.logOut, style: .destructive) {
                isLogoutInProgress = true
                model.logout(removeData: false)
            }
        )
    }
}
