import Foundation
import SwiftUI

struct SpaceChangeAccessViewModel: Identifiable {
    let id = UUID()
    let message: String
    let onConfirm: () -> Void
}

struct SpaceChangeAccessView: View {
    
    let model: SpaceChangeAccessViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        BottomAlertView(title: Loc.areYouSure, message: model.message) {
            BottomAlertButton(text: Loc.ok, style: .warning) {
                model.onConfirm()
                dismiss()
            }
            BottomAlertButton(text: Loc.cancel, style: .secondary) {
                dismiss()
            }
        }
    }
}
