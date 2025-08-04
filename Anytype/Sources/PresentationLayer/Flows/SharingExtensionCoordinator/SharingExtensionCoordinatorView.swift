import SwiftUI

struct SharingExtensionCoordinatorView: View {
    
    @StateObject private var model = SharingExtensionCoordinatorViewModel()
    
    var body: some View {
        SharingExtensionView(output: model)
            .sheet(item: $model.showShareTo) {
                SharingExtensionShareToView(data: $0)
            }
    }
}
