import Foundation
import SwiftUI

struct SpaceRequestViewModel: Identifiable {
    let id = UUID()
    let icon: Icon?
    let title: String
    let onViewAccess: () -> Void
    let onEditAccess: () -> Void
    let onReject: () -> Void
}

struct SpaceRequestView: View {
    
    let model: SpaceRequestViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        BottomAlertView(title: model.title, message: "") {
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.viewAccess, style: .secondary) {
                model.onViewAccess()
                dismiss()
            }
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.editAccess, style: .secondary) {
                model.onEditAccess()
                dismiss()
            }
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.reject, style: .warning) {
                model.onReject()
                dismiss()
            }
        }
    }
}
