import SwiftUI

struct DashboardAccountDeletionAlert: View {
    
    @StateObject private var model = DashboardAccountDeletionAlertModel()

    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        FloaterAlertView(
            title: Loc.DeletionAlert.title,
            description: Loc.DeletionAlert.description,
            leftButtonData: StandardButtonModel(text: Loc.back, style: .secondaryLarge) {
                presentationMode.wrappedValue.dismiss()
            },
            rightButtonData: StandardButtonModel(text: Loc.delete, style: .warningLarge) {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                model.accountDeletionConfirm()
            }
        )
        .onAppear {
            AnytypeAnalytics.instance().logScreenSettingsDelete()
        }
        .snackbar(toastBarData: $model.toastBarData)
    }
}
