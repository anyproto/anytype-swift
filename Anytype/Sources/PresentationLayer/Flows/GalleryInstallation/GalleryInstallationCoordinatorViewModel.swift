import Foundation
import SwiftUI
import Services
import AnytypeCore
@MainActor
final class GalleryInstallationCoordinatorViewModel: ObservableObject,
                                                     GalleryInstallationPreviewModuleOutput, GallerySpaceSelectionModuleOutput {
    
    private let data: GalleryInstallationData
    private let galleryInstallationPreviewModuleAssembly: GalleryInstallationPreviewModuleAssemblyProtocol
    private let gallerySpaceSelectionModuleAssembly: GallerySpaceSelectionModuleAssemblyProtocol
    private let galleryService: GalleryServiceProtocol
    private let workspaceService: WorkspaceServiceProtocol
    
    private var manifest: GalleryManifest?
    @Published var dismiss = false
    @Published var showSpaceSelection = false
    
    init(
        data: GalleryInstallationData,
        galleryInstallationPreviewModuleAssembly: GalleryInstallationPreviewModuleAssemblyProtocol,
        gallerySpaceSelectionModuleAssembly: GallerySpaceSelectionModuleAssemblyProtocol,
        galleryService: GalleryServiceProtocol,
        workspaceService: WorkspaceServiceProtocol
    ) {
        self.data = data
        self.galleryInstallationPreviewModuleAssembly = galleryInstallationPreviewModuleAssembly
        self.gallerySpaceSelectionModuleAssembly = gallerySpaceSelectionModuleAssembly
        self.galleryService = galleryService
        self.workspaceService = workspaceService
    }
    
    func previewModule() -> AnyView {
        galleryInstallationPreviewModuleAssembly.make(data: data, output: self)
    }
    
    func spaceSelectionModule() -> AnyView {
        gallerySpaceSelectionModuleAssembly.make(output: self)
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
                dismiss.toggle()
                try await galleryService.importExperience(spaceId: spaceId, isNewSpace: true, title: manifest.title, url: manifest.downloadLink)
            }
            AnytypeAnalytics.instance().logGalleryInstall(name: manifest.title)
        }
    }
}
