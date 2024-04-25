import Foundation
import SwiftUI

struct SpaceJoinConfirmationView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let onDone: () -> Void
    let onManageSpaces: () -> Void
    
    var body: some View {
        BottomAlertView(
            title: Loc.SpaceShare.JoinConfirmation.title,
            message: Loc.SpaceShare.JoinConfirmation.message
        ) {
            BottomAlertButton(text: Loc.done, style: .primary) {
                if #unavailable(iOS 17.0) {
                    dismiss()
                }
                onDone()
            }
            BottomAlertButton(text: Loc.SpaceShare.manageSpaces, style: .secondary) {
                if #unavailable(iOS 17.0) {
                    dismiss()
                }
                onManageSpaces()
            }
        }
    }
}

#Preview {
    SpaceJoinConfirmationView(onDone: {}, onManageSpaces: {})
}
