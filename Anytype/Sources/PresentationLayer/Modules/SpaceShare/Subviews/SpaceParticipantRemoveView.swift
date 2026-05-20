import Foundation
import SwiftUI

struct SpaceParticipantRemoveViewModel: Identifiable {
    let id = UUID()
    let onConfirm: () async throws -> Void
}

struct SpaceParticipantRemoveView: View {

    let model: SpaceParticipantRemoveViewModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        BottomAlertView(
            title: Loc.SpaceShare.RemoveMember.sheetTitle,
            message: Loc.SpaceShare.RemoveMember.message,
            icon: .Dialog.exclamation
        ) {
            BottomAlertButton(text: Loc.remove, style: .warning) {
                try await model.onConfirm()
                dismiss()
            }
            BottomAlertButton(text: Loc.cancel, style: .secondary) {
                dismiss()
            }
        }
    }
}
