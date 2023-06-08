import SwiftUI

struct DashboardDeletionAlert: View {
    @ObservedObject var model: HomeViewModel
    
    var body: some View {
        FloaterAlertView(
            title: Loc.areYouSureYouWantToDelete(model.numberOfSelectedPages),
            description: Loc.theseObjectsWillBeDeletedIrrevocably,
            leftButtonData: StandardButtonModel(text: Loc.cancel, style: .secondaryLarge) {
                model.showPagesDeletionAlert = false
            },
            rightButtonData: StandardButtonModel(text: "Delete", style: .warningLarge) {
                model.pagesDeleteConfirmation()
            },
            showShadow: true
        )
    }
}
