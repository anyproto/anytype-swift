import SwiftUI

struct StopSharingAnEmptySpaceAlert: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        BottomAlertView(
            title: Loc.SpaceShare.StopSharingEmptySpace.title,
            message: Loc.SpaceShare.StopSharingEmptySpace.message,
            icon: .Dialog.exclamation
        ) {
            BottomAlertButton(text: Loc.okay, style: .secondary) {
                dismiss()
            }
        }
    }
}
