import Foundation
import SwiftUI
import Services

struct GalleryInstallationPreviewView: View {
    
    @StateObject var model: GalleryInstallationPreviewViewModel
    
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
    }
}
