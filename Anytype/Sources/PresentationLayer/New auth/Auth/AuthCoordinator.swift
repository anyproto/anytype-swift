import SwiftUI

@MainActor
protocol AuthCoordinatorProtocol {
    func startFlow() -> AnyView
}

@MainActor
final class AuthCoordinator: AuthCoordinatorProtocol, AuthViewModelOutput {
    
    // MARK: - DI
    
    private let authModuleAssembly: AuthModuleAssemblyProtocol
    private let joinFlowCoordinator: JoinFlowCoordinatorProtocol
    
    init(authModuleAssembly: AuthModuleAssemblyProtocol, joinFlowCoordinator: JoinFlowCoordinatorProtocol) {
        self.authModuleAssembly = authModuleAssembly
        self.joinFlowCoordinator = joinFlowCoordinator
    }
    
    // MARK: - AuthCoordinatorProtocol
    
    func startFlow() -> AnyView {
        return authModuleAssembly.make(output: self)
    }
    
    // MARK: - AuthViewModelOutput
    
    func onJoinAction() -> AnyView {
        joinFlowCoordinator.startFlow()
    }
    
}
