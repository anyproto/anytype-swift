import SwiftUI

struct ShareInviteWithSpaceAlert: View {
    @Environment(\.dismiss) private var dismiss
    let onConfirm: () -> ()

    var body: some View {
        BottomAlertView(
            title: Loc.Space.Invite.Share.confirmTitle,
            message: Loc.Space.Invite.Share.confirmMessage,
            icon: .Dialog.exclamation
        ) {
            BottomAlertButton(text: Loc.cancel, style: .secondary) {
                dismiss()
            }
            BottomAlertButton(text: Loc.Space.Invite.Share.confirmButton, style: .primary) {
                onConfirm()
                dismiss()
            }
        }
    }
}

struct ResetInviteLinkAlert: View {
    @Environment(\.dismiss) private var dismiss
    let onConfirm: () -> ()

    var body: some View {
        BottomAlertView(
            title: Loc.Space.Invite.Reset.confirmTitle,
            message: Loc.Space.Invite.Reset.confirmMessage,
            icon: .Dialog.exclamation
        ) {
            BottomAlertButton(text: Loc.cancel, style: .secondary) {
                dismiss()
            }
            BottomAlertButton(text: Loc.Space.Invite.Reset.title, style: .warning) {
                onConfirm()
                dismiss()
            }
        }
    }
}
