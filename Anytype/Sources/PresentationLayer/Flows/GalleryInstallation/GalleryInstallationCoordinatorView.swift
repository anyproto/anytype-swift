import Foundation
import SwiftUI

struct GalleryInstallationCoordinatorView: View {

    @State private var model: GalleryInstallationCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss

    init(data: GalleryInstallationData) {
        _model = State(initialValue: GalleryInstallationCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        GalleryInstallationPreviewView(data: model.data, output: model)
            .sheet(isPresented: $model.showSpaceSelection) {
                GallerySpaceSelectionView(output: model)
            }
            .onChange(of: model.dismiss) {
                dismiss()
            }
    }
}
