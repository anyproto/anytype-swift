import Foundation
import SwiftUI

struct SpaceRequestAlertData: Identifiable {
    let id = UUID()
    let spaceId: String
    let spaceName: String
    let participantIdentity: String
    let participantName: String
}

struct SpaceRequestAlert: View {
    
    @StateObject private var model: SpaceRequestAlertModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: SpaceRequestAlertData) {
        _model = StateObject(wrappedValue: SpaceRequestAlertModel(data: data))
    }
    
    var body: some View {
        BottomAlertView(title: model.title, message: "") {
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.viewAccess, style: .secondary, disable: !model.canAddReaded) {
                try await model.onViewAccess()
                dismiss()
            }
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.editAccess, style: .secondary, disable: !model.canAddWriter) {
                try await model.onEditAccess()
                dismiss()
            }
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.reject, style: .warning) {
                try await model.onReject()
                dismiss()
            }
        }
        .throwTask {
            try await model.onAppear()
        }
    }
}
