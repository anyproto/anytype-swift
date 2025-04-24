import SwiftUI

struct ServerLocalConfigurationAlert: View {
    @Environment(\.dismiss) private var dismiss
    let actionApproved: () -> Void
    
    var body: some View {
        BottomAlertView(
            title: Loc.Server.LocalOnly.Alert.title,
            message: Loc.Server.LocalOnly.Alert.message,
            icon: .Dialog.exclamation
        ) {
            BottomAlertButton(text: Loc.Server.LocalOnly.Alert.Action.disagree, style: .secondary) {
                dismiss()
            }
            BottomAlertButton(text: Loc.Server.LocalOnly.Alert.Action.agree, style: .secondary) {
                actionApproved()
                dismiss()
            }
        }
    }
}
