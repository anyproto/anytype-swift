import Foundation
import SwiftUI

struct MakePrivateAlert: View {

    let onConfirm: () async throws -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        BottomAlertView(
            title: Loc.SpaceShare.MakePrivate.title,
            message: Loc.SpaceShare.MakePrivate.message,
            icon: .Dialog.lock
        ) {
            BottomAlertButton(text: Loc.SpaceShare.MakePrivate.confirm, style: .warning) {
                try await onConfirm()
                dismiss()
            }
            BottomAlertButton(text: Loc.cancel, style: .secondary) {
                dismiss()
            }
        }
    }
}
