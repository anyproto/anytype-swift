import Foundation
import Services

@MainActor
final class GalleryInstallationPreviewViewModel: ObservableObject {
    
    private let data: GalleryInstallationData
    private let galleryService: GalleryServiceProtocol
    private let formatter = ByteCountFormatter.fileFormatter
    
    private var manifest: GalleryManifest?
    @Published var state: State = .loading
    
    init(data: GalleryInstallationData, galleryService: GalleryServiceProtocol) {
        self.data = data
        self.galleryService = galleryService
        Task {
            await loadData()
        }
    }
    
    private func loadData() async {
        do {
            let manifest = try await galleryService.manifest(url: data.source)
            state = .data(manifest: makeViewManifest(manifest: manifest))
            self.manifest = manifest
        } catch {
            state = .error
        }
    }
    
    private func makeViewManifest(manifest: GalleryManifest) -> Manifest {
        let author = (manifest.author as NSString).lastPathComponent
        return Manifest(
            author: Loc.Gallery.author(author),
            title: manifest.title,
            description: manifest.description,
            screenshots: manifest.screenshots.compactMap { URL(string: $0) },
            fileSize: formatter.string(fromByteCount: Int64(manifest.fileSize)),
            categories: manifest.categories
        )
    }
}
