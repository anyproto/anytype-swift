import Foundation
import SwiftUI

struct DeleteSharingLinkAlert: View {
    
    @StateObject private var model: DeleteSharingLinkAlertModel
    @Environment(\.dismiss) private var dismiss
    
    init(spaceId: String) {
        self._model = StateObject(wrappedValue: DeleteSharingLinkAlertModel(spaceId: spaceId))
    }
    
    var body: some View {
        BottomAlertView(
            title: Loc.SpaceShare.DeleteSharingLink.title,
            message: Loc.SpaceShare.DeleteSharingLink.message) {
                BottomAlertButton(text: Loc.SpaceShare.DeleteSharingLink.confirm, style: .warning) {
                    try await model.onTapDeleteLink()
                    dismiss()
                }
                BottomAlertButton(text: Loc.cancel, style: .secondary) {
                    dismiss()
                }
            }
    }
    
}
