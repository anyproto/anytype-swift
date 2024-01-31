import Foundation
import Services

@MainActor
final class GalleryInstallationPreviewViewModel: ObservableObject {
    
    private let data: GalleryInstallationData
    private let galleryService: GalleryServiceProtocol
    
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
            state = .data(manifest: manifest)
        } catch {
            state = .error
        }
    }
}
