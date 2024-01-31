import Foundation
import SwiftUI

final class GalleryInstallationCoordinatorViewModel: ObservableObject {
    
    private let data: GalleryInstallationData
    private let galleryInstallationPreviewModuleAssembly: GalleryInstallationPreviewModuleAssemblyProtocol
    
    init(data: GalleryInstallationData, galleryInstallationPreviewModuleAssembly: GalleryInstallationPreviewModuleAssemblyProtocol) {
        self.data = data
        self.galleryInstallationPreviewModuleAssembly = galleryInstallationPreviewModuleAssembly
    }
    
    func previewModule() -> AnyView {
        galleryInstallationPreviewModuleAssembly.make()
    }
}
