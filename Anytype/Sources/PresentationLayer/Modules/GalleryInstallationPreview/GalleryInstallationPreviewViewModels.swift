import Foundation
import Services

extension GalleryInstallationPreviewViewModel {
    enum State {
        case data(manifest: GalleryManifest)
        case loading
        case error
        case install
    }
}
