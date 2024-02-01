import Foundation
import SwiftUI
import Services

struct GalleryInstallationPreviewView: View {
    
    @StateObject var model: GalleryInstallationPreviewViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Group {
            switch model.state {
            case .data(let manifest):
                GalleryInstallationPreviewManifestView(manifest: manifest, onTapInstall: { model.onTapInstall() })
            case .loading:
                EmptyView()
            case .error:
                EmptyView()
            case .install:
                EmptyView()
            }
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
}
