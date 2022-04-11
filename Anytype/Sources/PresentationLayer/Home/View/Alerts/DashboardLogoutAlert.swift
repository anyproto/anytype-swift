import SwiftUI
import Amplitude

struct DashboardLogoutAlert: View {
    @EnvironmentObject var model: SettingsViewModel
    
    @State private var isLogoutInProgress = false
    
    var body: some View {
        FloaterAlertView(
            title: "Have you backed up your keychain phrase?".localized,
            description: "Keychain phrase description".localized,
            leftButtonData: StandardButtonData(text: "Back up phrase".localized, style: .secondary) {
                model.keychain = true
                model.loggingOut = false
            },
            rightButtonData: StandardButtonData(inProgress: isLogoutInProgress, text: "Log out".localized, style: .destructive) {
                isLogoutInProgress = true
                model.logout(removeData: false)
            }
        )
    }
}
