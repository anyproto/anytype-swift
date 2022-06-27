import SwiftUI

struct DashboardAccountDeletionAlert: View {
    @EnvironmentObject var model: SettingsViewModel

    var body: some View {
        FloaterAlertView(
            title: Loc.DeletionAlert.title,
            description: Loc.DeletionAlert.description,
            leftButtonData: StandardButtonModel(text: Loc.back, style: .secondary) {
                model.accountDeleting = false
            },
            rightButtonData: StandardButtonModel(text: Loc.delete, style: .destructive) {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                model.accountDeletionConfirm()
            }
        )
    }
}
