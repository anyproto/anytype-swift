import SwiftUI

struct SharingExtensionCoordinatorView: View {
    
    @StateObject private var model = SharingExtensionCoordinatorViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        SharingExtensionView(output: model)
            .sheet(item: $model.showShareTo) {
                SharingExtensionShareToView(data: $0, output: model)
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
    }
}
