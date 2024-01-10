import Foundation
import SwiftUI

protocol GalleryInstallationCoordinatorAssemblyProtocol: AnyObject {
    func make() -> AnyView
}

final class GalleryInstallationCoordinatorAssembly: GalleryInstallationCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    
    init(modulesDI: ModulesDIProtocol) {
        self.modulesDI = modulesDI
    }
    
    // MARK: - GalleryInstallationCoordinatorAssemblyProtocol
    
    func make() -> AnyView {
        return GalleryInstallationCoordinatorView(
            model: GalleryInstallationCoordinatorViewModel(
                galleryInstallationPreviewModuleAssembly: self.modulesDI.galleryInstallationPreview()
            )
        ).eraseToAnyView()
    }
}
