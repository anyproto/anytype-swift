import SwiftUI

struct ObjectIsNotAvailableAlert: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        BottomAlertView(
            title: Loc.SpaceShare.Join.ObjectIsNotAvailable.title,
            message:  Loc.SpaceShare.Join.ObjectIsNotAvailable.message,
            icon: .BottomAlert.error,
            color: .red
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
