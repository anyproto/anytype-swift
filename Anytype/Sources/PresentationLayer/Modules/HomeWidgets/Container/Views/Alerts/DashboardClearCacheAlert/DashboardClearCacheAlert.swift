import SwiftUI
import AnytypeCore

struct DashboardClearCacheAlert: View {
    @ObservedObject var model: DashboardClearCacheAlertModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        FloaterAlertView(
            title: Loc.ClearCacheAlert.title,
            description: Loc.ClearCacheAlert.description,
            leftButtonData: StandardButtonModel(text: Loc.cancel, style: .secondaryLarge) {
                presentationMode.wrappedValue.dismiss()
            },
            rightButtonData: StandardButtonModel(text: Loc.delete, style: .warningLarge) {
                model.runClear {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        )
        .onAppear {
            model.onAppear()
        }
    }
}
