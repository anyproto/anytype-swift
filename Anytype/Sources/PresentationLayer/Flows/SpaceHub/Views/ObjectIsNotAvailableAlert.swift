import SwiftUI

struct ObjectIsNotAvailableAlert: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        BottomAlertView(
            title: Loc.SpaceShare.Join.objectIsNotAvailable,
            icon: .BottomAlert.sadMail,
            color: .blue
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
