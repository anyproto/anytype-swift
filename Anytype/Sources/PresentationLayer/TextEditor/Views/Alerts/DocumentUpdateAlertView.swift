import Foundation
import SwiftUI

struct DocumentUpdateAlertView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let cancel: () -> Void
    
    var body: some View {
        BottomAlertView(
            title: Loc.Error.AnytypeNeedsUpgrate.title,
            message: Loc.Error.AnytypeNeedsUpgrate.message,
            icon: .BottomAlert.update,
            style: .green
        ) {
            BottomAlertButton(text: Loc.close, style: .secondary) {
                dismiss()
                cancel()
            }
            BottomAlertButton(text: Loc.Error.AnytypeNeedsUpgrate.confirm, style: .primary) {
                dismiss()
            }
        }
    }
}
