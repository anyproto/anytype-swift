import Foundation
import SwiftUI

protocol GalleryInstallationCoordinatorAssemblyProtocol: AnyObject {
    func make(data: GalleryInstallationData) -> AnyView
}

final class GalleryInstallationCoordinatorAssembly: GalleryInstallationCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    
    init(modulesDI: ModulesDIProtocol) {
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
