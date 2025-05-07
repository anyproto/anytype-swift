import Foundation
import SwiftUI

struct DocumentUpdateAlertView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    let cancel: () -> Void
    
    var body: some View {
        BottomAlertView(
            title: Loc.Error.AnytypeNeedsUpgrate.title,
            message: Loc.Error.AnytypeNeedsUpgrate.message,
            icon: .Dialog.update
        ) {
            BottomAlertButton(text: Loc.close, style: .secondary) {
                dismiss()
                cancel()
            }
            BottomAlertButton(text: Loc.Error.AnytypeNeedsUpgrate.confirm, style: .primary) {
                guard let link = AppLinks.storeLink else { return }
                openURL(link)
                dismiss()
            }
        }
    }
}
