import SwiftUI
import AnytypeCore

struct DashboardClearCacheAlert: View {
    @ObservedObject var model: DashboardClearCacheAlertModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        FloaterAlertView(
            title: FeatureFlags.fileStorage ? Loc.ClearCacheAlert.title : Loc.clearCache,
            description: FeatureFlags.fileStorage ? Loc.ClearCacheAlert.description : Loc.clearCacheDescription,
            leftButtonData: StandardButtonModel(text: Loc.cancel, style: .secondaryLarge) {
                presentationMode.wrappedValue.dismiss()
            },
            rightButtonData: StandardButtonModel(text: FeatureFlags.fileStorage ? Loc.delete : Loc.clear, style: .warningLarge) {
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
