import SwiftUI

struct SharingExtensionCoordinatorView: View {

    @State private var model = SharingExtensionCoordinatorViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        SharingExtensionView(output: model, suggestedSpaceId: model.suggestedSpaceId)
            .sheet(item: $model.showShareTo) {
                SharingExtensionShareToView(data: $0, output: model)
            }
            .onChange(of: model.dismiss) {
                dismiss()
            }
            .task {
                await model.checkForSuggestedConversation()
            }
    }
}
