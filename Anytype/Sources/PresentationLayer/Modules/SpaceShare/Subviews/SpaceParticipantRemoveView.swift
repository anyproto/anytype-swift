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
        // TODO IOS-5601: replace placeholder icon with `.Dialog.removeMember` (orange person+X, Figma node 25848:11742) once asset is exported.
        BottomAlertView(
            title: Loc.SpaceShare.RemoveMember.title,
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
