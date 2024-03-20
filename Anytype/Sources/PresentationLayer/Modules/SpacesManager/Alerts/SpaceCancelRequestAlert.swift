import Foundation
import SwiftUI

struct SpaceCancelRequestAlert: View {
    
    @StateObject private var model: SpaceCancelRequestAlertModel
    @Environment(\.dismiss) private var dismiss
    
    init(spaceId: String) {
        self._model = StateObject(wrappedValue: SpaceCancelRequestAlertModel(spaceId: spaceId))
    }
    
    var body: some View {
        BottomAlertView(
            title: Loc.SpaceManager.CancelRequestAlert.title) {
                BottomAlertButton(text: Loc.SpaceManager.cancelRequest, style: .warning) {
                    try await model.onTapCancelEquest()
                    dismiss()
                }
                BottomAlertButton(text: Loc.SpaceManager.doNotCancel, style: .secondary) {
                    dismiss()
                }
            }
    }
}
