import Foundation
import SwiftUI

struct GalleryInstallationCoordinatorView: View {
    
    @StateObject var model: GalleryInstallationCoordinatorViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        model.previewModule()
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
}
