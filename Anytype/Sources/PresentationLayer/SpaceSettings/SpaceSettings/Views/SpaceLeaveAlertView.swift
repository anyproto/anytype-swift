import SwiftUI

struct SpaceLeaveAlertView: View {
    
    let spaceName: String
    let onConfirm: () async throws -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        BottomAlertView(
            title: Loc.SpaceSettings.LeaveAlert.title,
            message: Loc.SpaceSettings.LeaveAlert.message(spaceName)) {
                BottomAlertButton(text: Loc.SpaceSettings.leaveButton, style: .warning) {
                    try await onConfirm()
                    dismiss()
                }
                BottomAlertButton(text: Loc.cancel, style: .secondary) {
                    dismiss()
                }
            }
    }
}
