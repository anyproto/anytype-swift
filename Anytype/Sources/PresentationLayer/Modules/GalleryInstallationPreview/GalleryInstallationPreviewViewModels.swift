import Foundation
import Services

extension GalleryInstallationPreviewViewModel {
    enum State {
        case data(manifest: Manifest)
        case loading
        case error
        case install
    }
    
    struct Manifest {
        let author: String
        let title: String
        let description: String
        let screenshots: [URL]
        let fileSize: String
        let categories: [String]
    }
}
