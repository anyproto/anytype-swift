import Foundation
import SwiftUI
import Services

@MainActor
final class GalleryInstallationCoordinatorViewModel: ObservableObject, GalleryInstallationPreviewModuleOutput {
    
    private let data: GalleryInstallationData
    private let galleryInstallationPreviewModuleAssembly: GalleryInstallationPreviewModuleAssemblyProtocol
    private let galleryService: GalleryServiceProtocol
    private let workspaceService: WorkspaceServiceProtocol
    
    @Published var dismiss = false
    
    init(
        data: GalleryInstallationData,
        galleryInstallationPreviewModuleAssembly: GalleryInstallationPreviewModuleAssemblyProtocol,
        galleryService: GalleryServiceProtocol,
        workspaceService: WorkspaceServiceProtocol
    ) {
        self.data = data
        self.galleryInstallationPreviewModuleAssembly = galleryInstallationPreviewModuleAssembly
        self.galleryService = galleryService
        self.workspaceService = workspaceService
    }
    
    func previewModule() -> AnyView {
        galleryInstallationPreviewModuleAssembly.make(data: data, output: self)
    }
    
    // MARK: - GalleryInstallationPreviewModuleOutput
    
    func onSelectInstall(manifest: GalleryManifest) {
        Task {
            let spaceId = try await workspaceService.createSpace(name: manifest.title, gradient: .random, accessibility: .personal, useCase: .none)
            try await galleryService.importExperience(spaceId: spaceId, isNewSpace: true, title: manifest.title, url: manifest.downloadLink)
        }
        dismiss.toggle()
    }
}
