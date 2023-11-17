import SwiftUI

protocol SpaceSwitchModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(output: SpaceSwitchModuleOutput?) -> AnyView
}

final class SpaceSwitchModileAssembly: SpaceSwitchModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SpaceSwitchModuleAssemblyProtocol
    
    @MainActor
    func make(output: SpaceSwitchModuleOutput?) -> AnyView {
        return SpaceSwitchView(model: SpaceSwitchViewModel(
            workspacesStorage: self.serviceLocator.workspaceStorage(),
            activeWorkspaceStorage: self.serviceLocator.activeWorkspaceStorage(),
            subscriptionService: self.serviceLocator.singleObjectSubscriptionService(),
            accountManager: self.serviceLocator.accountManager(),
            workspaceService: self.serviceLocator.workspaceService(),
            output: output
        )).eraseToAnyView()
    }
}
