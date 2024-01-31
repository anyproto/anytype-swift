import Foundation
import SwiftUI
import Services

struct GalleryInstallationPreviewView: View {
    
    @StateObject var model: GalleryInstallationPreviewViewModel
    
    var body: some View {
        switch model.state {
        case .data(let manifest):
            GalleryInstallationPreviewManifestView(manifest: manifest)
        case .loading:
            Color.red
        case .error:
            Color.gray
        case .install:
            Color.orange
        }
    }
}
