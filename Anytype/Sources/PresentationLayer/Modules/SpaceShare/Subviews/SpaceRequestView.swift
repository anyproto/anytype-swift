import Foundation
import SwiftUI

struct SpaceRequestViewModel: Identifiable {
    let id = UUID()
    let icon: Icon?
    let title: String
    let onViewAccess: () async throws -> Void
    let onEditAccess: () async throws -> Void
    let onReject: () async throws -> Void
}

struct SpaceRequestView: View {
    
    let model: SpaceRequestViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        BottomAlertView(title: model.title, message: "") {
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.viewAccess, style: .secondary) {
                try await model.onViewAccess()
                dismiss()
            }
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.editAccess, style: .secondary) {
                try await model.onEditAccess()
                dismiss()
            }
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.reject, style: .warning) {
                try await model.onReject()
                dismiss()
            }
        }
    }
}
