import Foundation
import SwiftUI

struct StopSharingAlert: View {
    
    @StateObject private var model: StopSharingAlertModel
    @Environment(\.dismiss) private var dismiss
    
    init(spaceId: String, onStopShare: (() -> Void)? = nil) {
        self._model = StateObject(wrappedValue: StopSharingAlertModel(spaceId: spaceId, onStopShare: onStopShare))
    }
    
    var body: some View {
        BottomAlertView(
            title: Loc.SpaceShare.StopSharing.title,
            message: Loc.SpaceShare.StopSharing.message
        ) {
            BottomAlertButton(text: Loc.SpaceShare.StopSharing.action, style: .warning) {
                try await model.onTapStopShare()
                dismiss()
            }
            BottomAlertButton(text: Loc.cancel, style: .secondary) {
                dismiss()
            }
        }
        .snackbar(toastBarData: $model.toast)
        .onAppear {
            model.onAppear()
        }
    }
    
}
