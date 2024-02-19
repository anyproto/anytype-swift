import Foundation
import SwiftUI

@MainActor
protocol GalleryInstallationPreviewModuleAssemblyProtocol: AnyObject {
    func make(data: GalleryInstallationData, output: GalleryInstallationPreviewModuleOutput?) -> AnyView
}

@MainActor
final class GalleryInstallationPreviewModuleAssembly: GalleryInstallationPreviewModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - GalleryInstallationPreviewModuleAssemblyProtocol
    
    func make(data: GalleryInstallationData, output: GalleryInstallationPreviewModuleOutput?) -> AnyView {
        return GalleryInstallationPreviewView(
            model: GalleryInstallationPreviewViewModel(
                data: data,
                galleryService: self.serviceLocator.galleryService(),
                output: output
            )
        ).eraseToAnyView()
    }
}
