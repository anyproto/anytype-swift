import Foundation
import SwiftUI

protocol GalleryInstallationPreviewModuleAssemblyProtocol: AnyObject {
    func make() -> AnyView
}

final class GalleryInstallationPreviewModuleAssembly: GalleryInstallationPreviewModuleAssemblyProtocol {
    
    // MARK: - GalleryInstallationPreviewModuleAssemblyProtocol
    
    func make() -> AnyView {
        return GalleryInstallationPreviewView(model: GalleryInstallationPreviewViewModel()).eraseToAnyView()
    }
}
