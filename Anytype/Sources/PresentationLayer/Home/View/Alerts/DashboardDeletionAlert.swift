import SwiftUI

struct DashboardDeletionAlert: View {
    @EnvironmentObject private var model: HomeViewModel
    
    var body: some View {
        FloaterAlertView(
            title: "\("Are you sure you want to delete".localized) \(model.numberOfSelectedPages) \(objectsLiteral)?",
            description: "These objects will be deleted irrevocably. You can’t undo this action.".localized,
            cancelButtonData: StandardButtonData(text: "Cancel".localized, style: .secondary) {
                model.showDeletionAlert = false
            },
            destructiveButtonData: StandardButtonData(text: "Delete", style: .destructive) {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                model.deleteConfirmation()
                model.showDeletionAlert = false
            }
        )
    }
    
    private var objectsLiteral: String {
        model.numberOfSelectedPages == 1 ? "object".localized : "objects".localized
    }
}
