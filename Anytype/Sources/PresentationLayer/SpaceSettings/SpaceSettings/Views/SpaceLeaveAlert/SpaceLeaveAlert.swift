import SwiftUI

struct SpaceLeaveAlert: View {
    
    @StateObject private var model: SpaceLeaveAlertModel
    @Environment(\.dismiss) private var dismiss
    
    init(spaceId: String) {
        self._model = StateObject(wrappedValue: SpaceLeaveAlertModel(spaceId: spaceId))
    }
    
    var body: some View {
        BottomAlertView(
            title: Loc.leaveASpace,
            message: Loc.SpaceSettings.LeaveAlert.message(model.spaceName)
        ) {
            BottomAlertButton(text: Loc.SpaceSettings.leaveButton, style: .warning) {
                try await model.onTapLeave()
                dismiss()
            }
            BottomAlertButton(text: Loc.cancel, style: .secondary) {
                dismiss()
            }
        }
        .snackbar(toastBarData: $model.toast)
        .onAppear {
            model.onAppear()
        }
    }
}
