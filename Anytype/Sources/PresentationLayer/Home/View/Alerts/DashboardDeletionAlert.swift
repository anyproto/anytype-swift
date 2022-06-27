import SwiftUI

struct DashboardDeletionAlert: View {
    @EnvironmentObject private var model: HomeViewModel
    
    var body: some View {
        FloaterAlertView(
            title: Loc.areYouSureYouWantToDelete(model.numberOfSelectedPages),
            description: "These objects will be deleted irrevocably. You can’t undo this action.".localized,
            leftButtonData: StandardButtonModel(text: Loc.cancel, style: .secondary) {
                model.showPagesDeletionAlert = false
            },
            rightButtonData: StandardButtonModel(text: "Delete", style: .destructive) {
                model.pagesDeleteConfirmation()
            }
        )
    }
}
