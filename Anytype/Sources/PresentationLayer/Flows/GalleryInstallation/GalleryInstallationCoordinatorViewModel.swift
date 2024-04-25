import Foundation
import SwiftUI
import Services
import AnytypeCore

@MainActor
final class GalleryInstallationCoordinatorViewModel: ObservableObject,
                                                     GalleryInstallationPreviewModuleOutput, GallerySpaceSelectionModuleOutput {
    
    let data: GalleryInstallationData
    @Injected(\.galleryService)
    private var galleryService: GalleryServiceProtocol
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    
    private var manifest: GalleryManifest?
    @Published var dismiss = false
    @Published var showSpaceSelection = false
    
    init(data: GalleryInstallationData) {
        self.data = data
    }
    
    // MARK: - GalleryInstallationPreviewModuleOutput
    
    func onSelectInstall(manifest: GalleryManifest) {
        self.manifest = manifest
        showSpaceSelection = true
    }
    
    // MARK: - GallerySpaceSelectionModuleOutput
    
    func onSelectSpace(result: GallerySpaceSelectionResult) {
        guard let manifest else {
            anytypeAssertionFailure("Manifest is empty")
            return
        }
        Task {
            switch result {
            case .space(let spaceId):
                dismiss.toggle()
                try await galleryService.importExperience(spaceId: spaceId, isNewSpace: false, title: manifest.title, url: manifest.downloadLink)
            case .newSpace:
                let spaceId = try await workspaceService.createSpace(name: manifest.title, gradient: .random, accessType: .personal, useCase: .none)
                AnytypeAnalytics.instance().logCreateSpace(route: .gallery)
                dismiss.toggle()
                try await galleryService.importExperience(spaceId: spaceId, isNewSpace: true, title: manifest.title, url: manifest.downloadLink)
            }
            AnytypeAnalytics.instance().logGalleryInstall(name: manifest.title)
        }
    }
}
