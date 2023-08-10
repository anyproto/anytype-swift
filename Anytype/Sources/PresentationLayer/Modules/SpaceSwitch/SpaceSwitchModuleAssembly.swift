import SwiftUI

protocol SpaceSwitchModileAssemblyProtocol: AnyObject {
    @MainActor
    func make(output: SpaceSwitchModuleOutput?) -> AnyView
}

final class SpaceSwitchModileAssembly: SpaceSwitchModileAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SpaceSwitchModileAssemblyProtocol
    
    @MainActor
    func make(output: SpaceSwitchModuleOutput?) -> AnyView {
        return SpaceSwitchView(model: SpaceSwitchViewModel(
            workspacesStorage: self.serviceLocator.workspaceStorage(),
            activeWorkspaceStorage: self.serviceLocator.activeWorkspaceStorage(),
            subscriptionService: self.serviceLocator.singleObjectSubscriptionService(),
            workspaceService: self.serviceLocator.workspaceService(),
            output: output
        )).eraseToAnyView()
    }
}
