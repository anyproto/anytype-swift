import SwiftUI

struct ServerLocalConfigurationAlert: View {
    @Environment(\.dismiss) private var dismiss
    let actionApproved: () -> Void
    
    var body: some View {
        BottomAlertView(
            title: Loc.Server.LocalOnly.Alert.title,
            message: Loc.Server.LocalOnly.Alert.message,
            icon: .BottomAlert.exclamation,
            style: .plain
        ) {
            BottomAlertButton(text: Loc.Server.LocalOnly.Alert.Action.primary, style: .primary) {
                actionApproved()
                dismiss()
            }
            BottomAlertButton(text: Loc.Server.LocalOnly.Alert.Action.secondary, style: .secondary) {
                dismiss()
            }
        }
    }
}