import SwiftUI

@MainActor
protocol AuthCoordinatorProtocol {
    func startFlow() -> AnyView
}

@MainActor
final class AuthCoordinator: AuthCoordinatorProtocol, AuthViewModelOutput {
    
    // MARK: - DI
    
    private let joinFlowCoordinator: any JoinFlowCoordinatorProtocol
    private let loginFlowCoordinator: any LoginFlowCoordinatorProtocol
    
    init(
        joinFlowCoordinator: some JoinFlowCoordinatorProtocol,
        loginFlowCoordinator: some LoginFlowCoordinatorProtocol
    ) {
        self.joinFlowCoordinator = joinFlowCoordinator
        self.loginFlowCoordinator = loginFlowCoordinator
    }
    
    // MARK: - AuthCoordinatorProtocol
    
    func startFlow() -> AnyView {
        AuthView(output: self).eraseToAnyView()
    }
    
    // MARK: - AuthViewModelOutput
    
    func onJoinAction(state: JoinFlowState) -> AnyView {
        joinFlowCoordinator.startFlow(state: state)
    }
    
    func onLoginAction() -> AnyView {
        loginFlowCoordinator.startFlow()
    }
    
    func onSettingsAction() -> AnyView {
        ServerConfigurationCoordinatorView().eraseToAnyView()
    }
}
