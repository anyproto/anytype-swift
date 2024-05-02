import SwiftUI

struct DashboardAccountDeletionAlert: View {
    
    @StateObject private var model = DashboardAccountDeletionAlertModel()

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        BottomAlertView(
            title: Loc.DeletionAlert.title,
            message: Loc.DeletionAlert.description
        ) {
            BottomAlertButton(text: Loc.back, style: .secondary) {
                dismiss()
            }
            BottomAlertButton(text: Loc.delete, style: .warning) {
                await model.accountDeletionConfirm()
            }
        }
        .onAppear {
            AnytypeAnalytics.instance().logScreenSettingsDelete()
        }
        .snackbar(toastBarData: $model.toastBarData)
    }
}
