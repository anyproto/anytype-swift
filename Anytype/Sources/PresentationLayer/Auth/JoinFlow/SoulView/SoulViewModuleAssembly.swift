import SwiftUI

protocol SoulViewModuleAssemblyProtocol {
    @MainActor
    func make(state: JoinFlowState, output: JoinFlowStepOutput?) -> AnyView
}

final class SoulViewModuleAssembly: SoulViewModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SoulViewModuleAssemblyProtocol
    
    @MainActor
    func make(state: JoinFlowState, output: JoinFlowStepOutput?) -> AnyView {
        return SoulView(
            model: SoulViewModel(
                state: state,
                output: output,
                accountManager: self.serviceLocator.accountManager(),
                objectActionsService: self.serviceLocator.objectActionsService(),
                authService: self.serviceLocator.authService(),
                seedService:  self.serviceLocator.seedService(),
                usecaseService: self.serviceLocator.usecaseService(),
                workspaceService: self.serviceLocator.workspaceService(), 
                activeWorkspaceStorage: self.serviceLocator.activeWorkspaceStorage()
            )
        ).eraseToAnyView()
    }
}
