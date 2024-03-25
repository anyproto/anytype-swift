import SwiftUI

struct SpaceDeleteAlert: View {
    
    @StateObject private var model: SpaceDeleteAlertModel
    @Environment(\.dismiss) private var dismiss
    
    init(spaceId: String) {
        self._model = StateObject(wrappedValue: SpaceDeleteAlertModel(spaceId: spaceId))
    }
    
    var body: some View {
        BottomAlertView(
            title: Loc.SpaceSettings.DeleteAlert.title(model.spaceName),
            message: Loc.SpaceSettings.DeleteAlert.message) {
                BottomAlertButton(text: Loc.delete, style: .warning) {
                    try await model.onTapDelete()
                    dismiss()
                }
                BottomAlertButton(text: Loc.cancel, style: .secondary) {
                    model.onTapCancel()
                    dismiss()
                }
            }
    }
}
