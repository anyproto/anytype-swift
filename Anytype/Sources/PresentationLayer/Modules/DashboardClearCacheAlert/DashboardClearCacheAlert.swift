import SwiftUI
import AnytypeCore

struct DashboardClearCacheAlert: View {
    @StateObject private var model = DashboardClearCacheAlertModel()
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        BottomAlertView(
            title: Loc.ClearCacheAlert.title,
            message: Loc.ClearCacheAlert.description,
            buttons: {
                BottomAlertButton(text: Loc.cancel, style: .secondary) {
                    dismiss()
                }
                BottomAlertButton(text: Loc.delete, style: .warning) {
                    try await model.runClear()
                    dismiss()
                }
            }
        )
        .onAppear {
            model.onAppear()
        }
        .snackbar(toastBarData: $model.toastBarData)
    }
}
