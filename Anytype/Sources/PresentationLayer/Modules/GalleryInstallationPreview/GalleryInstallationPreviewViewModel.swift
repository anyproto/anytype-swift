import Foundation
import Services
import AnytypeCore

@MainActor
protocol GalleryInstallationPreviewModuleOutput: AnyObject {
    func onSelectInstall(manifest: GalleryManifest)
}

@MainActor
final class GalleryInstallationPreviewViewModel: ObservableObject {
    
    private let data: GalleryInstallationData
    private let galleryService: GalleryServiceProtocol
    private let formatter = ByteCountFormatter.fileFormatter
    private weak var output: GalleryInstallationPreviewModuleOutput?
    
    private var manifest: GalleryManifest?
    @Published var state: State = .loading(manifest: .placeholder)
    
    init(
        data: GalleryInstallationData,
        galleryService: GalleryServiceProtocol,
        output: GalleryInstallationPreviewModuleOutput?
    ) {
        self.data = data
        self.galleryService = galleryService
        self.output = output
        Task { await loadData() }
    }
    
    func onTapInstall() {
        guard let manifest else {
            anytypeAssertionFailure("Try to install without manifest")
            return
        }
        AnytypeAnalytics.instance().logClickGalleryInstall()
        output?.onSelectInstall(manifest: manifest)
    }
    
    func onTryAgainTap() {
        Task { await loadData() }
    }
    
    private func loadData() async {
        state = .loading(manifest: .placeholder)
        do {
            let manifest = try await galleryService.manifest(url: data.source)
            state = .data(manifest: makeViewManifest(manifest: manifest))
            self.manifest = manifest
            AnytypeAnalytics.instance().logScreenGalleryInstall(name: manifest.title)
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
