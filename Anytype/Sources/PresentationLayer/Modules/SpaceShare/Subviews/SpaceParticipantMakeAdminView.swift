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
        // TODO IOS-5601: replace placeholder icon with `.Dialog.makeAdmin` (green person+gear, Figma node 25848:11813) once asset is exported.
        BottomAlertView(
            title: Loc.SpaceShare.MakeAdmin.title,
            message: Loc.SpaceShare.MakeAdmin.message,
            icon: .Dialog.invite
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
