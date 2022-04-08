import SwiftUI

struct DashboardDeletionAlert: View {
    @EnvironmentObject private var model: HomeViewModel
    
    var body: some View {
        FloaterAlertView(
            title: "\("Are you sure you want to delete".localized) \(model.numberOfSelectedPages) \(objectsLiteral)?",
            description: "These objects will be deleted irrevocably. You can’t undo this action.".localized,
            leftButtonData: StandardButtonModel(text: "Cancel".localized, style: .secondary) {
                model.showPagesDeletionAlert = false
            },
            rightButtonData: StandardButtonModel(text: "Delete", style: .destructive) {
                model.pagesDeleteConfirmation()
            }
        )
    }
    
    private var objectsLiteral: String {
        model.numberOfSelectedPages == 1 ? "object".localized : "objects".localized
    }
}
