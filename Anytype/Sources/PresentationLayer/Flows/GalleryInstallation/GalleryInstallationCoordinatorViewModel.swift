import Foundation
import SwiftUI

final class GalleryInstallationCoordinatorViewModel: ObservableObject {
    
    let galleryInstallationPreviewModuleAssembly: GalleryInstallationPreviewModuleAssemblyProtocol
    
    init(galleryInstallationPreviewModuleAssembly: GalleryInstallationPreviewModuleAssemblyProtocol) {
        self.galleryInstallationPreviewModuleAssembly = galleryInstallationPreviewModuleAssembly
    }
    
    func previewModule() -> AnyView {
        galleryInstallationPreviewModuleAssembly.make()
    }
}
