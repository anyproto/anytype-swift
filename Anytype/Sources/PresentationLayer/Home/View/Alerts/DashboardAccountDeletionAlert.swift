import SwiftUI

struct DashboardAccountDeletionAlert: View {
    @EnvironmentObject var model: SettingsViewModel

    var body: some View {
        FloaterAlertView(
            title: "Are you sure to delete account?".localized,
            description: "You will be logged out on all other devices. You will have 30 days to recover it. Afterwards it will be deleted permanently".localized,
            leftButtonData: StandardButtonData(text: "Back".localized, style: .secondary) {
                model.accountDeleting = false
            },
            rightButtonData: StandardButtonData(text: "Delete".localized, style: .destructive) {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                model.accountDeletionConfirm()
            }
        )
    }
}
