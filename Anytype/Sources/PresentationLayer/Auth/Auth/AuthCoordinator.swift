import SwiftUI

@MainActor
protocol AuthCoordinatorProtocol {
    func startFlow() -> AnyView
}

@MainActor
final class AuthCoordinator: AuthCoordinatorProtocol, AuthViewModelOutput {
    
    // MARK: - DI
    
    private let joinFlowCoordinator: JoinFlowCoordinatorProtocol
    private let loginFlowCoordinator: LoginFlowCoordinatorProtocol
    
    init(
        joinFlowCoordinator: JoinFlowCoordinatorProtocol,
        loginFlowCoordinator: LoginFlowCoordinatorProtocol
    ) {
        self.joinFlowCoordinator = joinFlowCoordinator
        self.loginFlowCoordinator = loginFlowCoordinator
    }
    
    // MARK: - AuthCoordinatorProtocol
    
    func startFlow() -> AnyView {
        AuthView(output: self).eraseToAnyView()
    }
    
    // MARK: - AuthViewModelOutput
    
    func onJoinAction() -> AnyView {
        joinFlowCoordinator.startFlow()
    }
    
    func onLoginAction() -> AnyView {
        loginFlowCoordinator.startFlow()
    }
    
    func onSettingsAction() -> AnyView {
        ServerConfigurationCoordinatorView().eraseToAnyView()
    }
}
