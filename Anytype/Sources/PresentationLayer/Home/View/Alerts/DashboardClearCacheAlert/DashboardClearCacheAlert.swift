import SwiftUI

struct DashboardClearCacheAlert: View {
    @ObservedObject var model: DashboardClearCacheAlertModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        FloaterAlertView(
            title: Loc.clearCache,
            description: Loc.clearCacheDescription,
            leftButtonData: StandardButtonModel(text: Loc.cancel, style: .secondaryLarge) {
                presentationMode.wrappedValue.dismiss()
            },
            rightButtonData: StandardButtonModel(text: Loc.clear, style: .warningLarge) {
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
