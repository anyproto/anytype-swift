import Foundation
import SwiftUI

struct SpaceChangeAccessViewModel: Identifiable {
    let id = UUID()
    let participantName: String
    let permissions: String
    let onConfirm: () async throws -> Void
}

struct SpaceChangeAccessView: View {
    
    let model: SpaceChangeAccessViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        BottomAlertView(title: Loc.areYouSure, message: Loc.SpaceShare.changePermissions(model.participantName, model.permissions)) {
            BottomAlertButton(text: Loc.ok, style: .warning) {
                try await model.onConfirm()
                dismiss()
            }
            BottomAlertButton(text: Loc.cancel, style: .secondary) {
                dismiss()
            }
        }
    }
}
