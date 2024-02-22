import Foundation
import Services

extension GalleryInstallationPreviewViewModel {
    enum State {
        case data(manifest: Manifest)
        case loading(manifest: Manifest)
        case error
    }
    
    struct Manifest {
        let author: String
        let title: String
        let description: String
        let screenshots: [URL]
        let fileSize: String
        let categories: [String]
        
        static var placeholder: Self {
            Manifest(
                author: "Aaaaaaaaaa",
                title: "Aaaaaaaaaaa",
                description: "Aaaaaaa aaaaa aaaaaa aaaaaaa aaaaaa aaaaaa aaaaaa aaaaaa aaaaaaa aaaaaa aaaaaa aaaaaa aaaaaa aaaaaaa aaaaaa aaaaaa aaaaaa aaaaaa aaaaaaa aaaaaa aaaaaa aaaaaa",
                screenshots: [URL(fileURLWithPath: "")],
                fileSize: "",
                categories: ["Aaaaa", "Bbbbbb"]
            )
                
        }
    }
}
