import Foundation
import SwiftUI

@MainActor
protocol GallerySpaceSelectionModuleAssemblyProtocol: AnyObject {
    func make(output: GallerySpaceSelectionModuleOutput?) -> AnyView
}

@MainActor
final class GallerySpaceSelectionModuleAssembly: GallerySpaceSelectionModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - GalleryInstallationPreviewModuleAssemblyProtocol
    
    func make(output: GallerySpaceSelectionModuleOutput?) -> AnyView {
        return GallerySpaceSelectionView(
            model: GallerySpaceSelectionViewModel(
                workspaceStorage: self.serviceLocator.workspaceStorage(),
                output: output
            )
        ).eraseToAnyView()
    }
}
