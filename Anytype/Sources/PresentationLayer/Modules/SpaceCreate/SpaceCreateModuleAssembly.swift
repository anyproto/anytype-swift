import SwiftUI

protocol SpaceCreateModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make() -> AnyView
}

final class SpaceCreateModuleAssembly: SpaceCreateModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SpaceCreateModuleAssemblyProtocol
    
    @MainActor
    func make() -> AnyView {
        return SpaceCreateView(model: SpaceCreateViewModel(
            activeWorkspaceStorage: self.serviceLocator.activeWorkspaceStorage(),
            workspaceService: self.serviceLocator.workspaceService()
        )).eraseToAnyView()
    }
}
