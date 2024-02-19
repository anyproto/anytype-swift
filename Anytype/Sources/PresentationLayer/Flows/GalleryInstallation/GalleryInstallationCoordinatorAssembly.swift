import Foundation
import SwiftUI

@MainActor
protocol GalleryInstallationCoordinatorAssemblyProtocol: AnyObject {
    func make(data: GalleryInstallationData) -> AnyView
}

@MainActor
final class GalleryInstallationCoordinatorAssembly: GalleryInstallationCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let serviceLocator: ServiceLocator
    
    nonisolated init(modulesDI: ModulesDIProtocol, serviceLocator: ServiceLocator) {
        self.modulesDI = modulesDI
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - GalleryInstallationCoordinatorAssemblyProtocol
    
    func make(data: GalleryInstallationData) -> AnyView {
        return GalleryInstallationCoordinatorView(
            model: GalleryInstallationCoordinatorViewModel(
                data: data,
                galleryInstallationPreviewModuleAssembly: self.modulesDI.galleryInstallationPreview(),
                gallerySpaceSelectionModuleAssembly: self.modulesDI.gallerySpaceSelectionModuleAssembly(),
                galleryService: self.serviceLocator.galleryService(),
                workspaceService: self.serviceLocator.workspaceService()
            )
        ).eraseToAnyView()
    }
}
