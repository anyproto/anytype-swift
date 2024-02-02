import Foundation
import SwiftUI

struct GalleryInstallationCoordinatorView: View {
    
    @StateObject var model: GalleryInstallationCoordinatorViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        model.previewModule()
            .sheet(isPresented: $model.showSpaceSelection) {
                model.spaceSelectionModule()
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
    }
}
