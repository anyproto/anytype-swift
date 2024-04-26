import Foundation
import SwiftUI

protocol ShareCoordinatorAssemblyProtocol {
    @MainActor
    func make() -> AnyView
}

final class ShareCoordinatorAssembly: ShareCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let serviceLocator: ServiceLocator
    
    init(
        modulesDI: ModulesDIProtocol,
        serviceLocator: ServiceLocator
    ) {
        self.modulesDI = modulesDI
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - ShareCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> AnyView {
        return ShareCoordinatorView(model: ShareCoordinatorViewModel(
            shareOptionsModuleAssembly: self.modulesDI.shareOptions(),
            searchModuleAssembly: self.modulesDI.search(),
            activeWorkspaceStorage: self.serviceLocator.activeWorkspaceStorage()
        )).eraseToAnyView()
    }
}

