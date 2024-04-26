import Foundation
import SwiftUI

struct SpaceParticipantRemoveViewModel: Identifiable {
    let id = UUID()
    let participantName: String
    let onConfirm: () async throws -> Void
}

struct SpaceParticipantRemoveView: View {
    
    let model: SpaceParticipantRemoveViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        BottomAlertView(
            title: Loc.SpaceShare.RemoveMember.title,
            message: Loc.SpaceShare.RemoveMember.message(model.participantName)
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
