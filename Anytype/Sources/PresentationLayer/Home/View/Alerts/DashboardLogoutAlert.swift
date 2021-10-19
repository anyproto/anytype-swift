import SwiftUI
import Amplitude

struct DashboardLogoutAlert: View {
    @EnvironmentObject var settingsModel: SettingsViewModel
    @EnvironmentObject private var selectionModel: SettingSectionViewModel
    
    var body: some View {
        FloaterAlertView(
            title: "Have you backed up your keychain phrase?".localized,
            description: "Keychain phrase description".localized,
            leftButtonData: StandardButtonData(text: "Backup phrase".localized, style: .secondary) {
                selectionModel.keychain = true
                selectionModel.loggingOut = false
            },
            rightButtonData: StandardButtonData(text: "Log out".localized, style: .destructive) {
                Amplitude.instance().logEvent(AmplitudeEventsName.buttonProfileLogOut)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                settingsModel.logout()
            }
        )
    }
}
