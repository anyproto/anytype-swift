import Foundation
import SwiftUI

struct SpaceParticipantMakeAdminViewModel: Identifiable {
    let id = UUID()
    let onConfirm: () async throws -> Void
}

struct SpaceParticipantMakeAdminView: View {

    let model: SpaceParticipantMakeAdminViewModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        BottomAlertView(
            title: Loc.SpaceShare.MakeAdmin.title,
            message: Loc.SpaceShare.MakeAdmin.message,
            icon: .Dialog.makeAdmin
        ) {
            BottomAlertButton(text: Loc.SpaceShare.MakeAdmin.button, style: .warning) {
                try await model.onConfirm()
                dismiss()
            }
            BottomAlertButton(text: Loc.cancel, style: .secondary) {
                dismiss()
            }
        }
    }
}
