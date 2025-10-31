import SwiftUI

struct SpaceInviteChangeAlert: View {
    @Environment(\.dismiss) private var dismiss
    let onConfirm: () -> ()
    
    var body: some View {
        BottomAlertView(
            title: Loc.SpaceInvite.Alert.title,
            message: Loc.SpaceInvite.Alert.subtitle,
            icon: .Dialog.exclamation
        ) {
            BottomAlertButton(text: Loc.cancel, style: .secondary) {
                dismiss()
            }
            BottomAlertButton(text: Loc.confirm, style: .primary) {
                onConfirm()
                dismiss()
            }
        }.eraseToAnyView()
    }
}
