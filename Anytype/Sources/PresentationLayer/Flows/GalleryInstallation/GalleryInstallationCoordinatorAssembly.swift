import Foundation
import SwiftUI

@MainActor
protocol GalleryInstallationCoordinatorAssemblyProtocol: AnyObject {
    func make(data: GalleryInstallationData) -> AnyView
}

@MainActor
final class GalleryInstallationCoordinatorAssembly: GalleryInstallationCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    
    nonisolated init(modulesDI: ModulesDIProtocol) {
        self.modulesDI = modulesDI
    }
    
    // MARK: - GalleryInstallationCoordinatorAssemblyProtocol
    
    func make(data: GalleryInstallationData) -> AnyView {
        return GalleryInstallationCoordinatorView(
            model: GalleryInstallationCoordinatorViewModel(
                data: data,
                galleryInstallationPreviewModuleAssembly: self.modulesDI.galleryInstallationPreview()
            )
        ).eraseToAnyView()
    }
}
