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
    private let urlOpener: URLOpenerProtocol
    
    init(
        joinFlowCoordinator: JoinFlowCoordinatorProtocol,
        loginFlowCoordinator: LoginFlowCoordinatorProtocol,
        urlOpener: URLOpenerProtocol
    ) {
        self.joinFlowCoordinator = joinFlowCoordinator
        self.loginFlowCoordinator = loginFlowCoordinator
        self.urlOpener = urlOpener
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
    
    func onUrlAction(_ url: URL) {
        urlOpener.openUrl(url, presentationStyle: .pageSheet, preferredColorScheme: .dark)
    }
    
    func onSettingsAction() -> AnyView {
        ServerConfigurationCoordinatorView().eraseToAnyView()
    }
}
