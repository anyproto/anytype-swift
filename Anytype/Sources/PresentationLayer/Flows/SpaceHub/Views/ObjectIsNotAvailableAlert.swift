import SwiftUI

struct ObjectIsNotAvailableAlert: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        BottomAlertView(
            title: Loc.SpaceShare.Join.NoAccess.title,
            message:  Loc.SpaceShare.Join.ObjectIsNotAvailable.message,
            icon: .Dialog.duck
        ) {
            BottomAlertButton(
                text: Loc.okay,
                style: .secondary,
                action: {
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    ObjectIsNotAvailableAlert()
}
