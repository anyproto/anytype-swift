import Foundation
import SwiftUI

struct SpaceJoinConfirmationView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let done: () -> Void
    
    var body: some View {
        BottomAlertView(
            title: Loc.SpaceShare.JoinConfirmation.title,
            message: Loc.SpaceShare.JoinConfirmation.message
        ) {
            BottomAlertButton(text: Loc.done, style: .primary) {
                if #available(iOS 17.0, *) {} else {
                    dismiss()
                }
                done()
            }
        }
    }
}

#Preview {
    SpaceJoinConfirmationView(done: {})
}
