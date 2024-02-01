import Foundation
import Services
import AnytypeCore

@MainActor
final class GalleryInstallationPreviewViewModel: ObservableObject {
    
    private let data: GalleryInstallationData
    private let galleryService: GalleryServiceProtocol
    private let formatter = ByteCountFormatter.fileFormatter
    private let workspaceService: WorkspaceServiceProtocol
    
    private var manifest: GalleryManifest?
    @Published var state: State = .loading
    @Published var dismiss = false
    
    init(data: GalleryInstallationData, galleryService: GalleryServiceProtocol, workspaceService: WorkspaceServiceProtocol) {
        self.data = data
        self.galleryService = galleryService
        self.workspaceService = workspaceService
        Task {
            await loadData()
        }
    }
    
    func onTapInstall() {
        guard let manifest else {
            anytypeAssertionFailure("Try to install without manifest")
            return
        }
        Task {
            let spaceId = try await workspaceService.createSpace(name: manifest.title, gradient: .random, accessibility: .personal, useCase: .none)
            try await galleryService.importExperience(spaceId: spaceId, isNewSpace: true, title: manifest.title, url: manifest.downloadLink)
            dismiss.toggle()
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
