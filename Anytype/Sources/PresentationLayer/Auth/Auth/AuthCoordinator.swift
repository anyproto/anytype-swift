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
    private let loginFlowCoordinator: LoginFlowCoordinatorProtocol
    private let serverConfigurationCoordinatorAssembly: ServerConfigurationCoordinatorAssemblyProtocol
    private let urlOpener: URLOpenerProtocol
    
    init(
        authModuleAssembly: AuthModuleAssemblyProtocol,
        joinFlowCoordinator: JoinFlowCoordinatorProtocol,
        loginFlowCoordinator: LoginFlowCoordinatorProtocol,
        serverConfigurationCoordinatorAssembly: ServerConfigurationCoordinatorAssemblyProtocol,
        urlOpener: URLOpenerProtocol
    ) {
        self.authModuleAssembly = authModuleAssembly
        self.joinFlowCoordinator = joinFlowCoordinator
        self.loginFlowCoordinator = loginFlowCoordinator
        self.serverConfigurationCoordinatorAssembly = serverConfigurationCoordinatorAssembly
        self.urlOpener = urlOpener
    }
    
    // MARK: - AuthCoordinatorProtocol
    
    func startFlow() -> AnyView {
        return authModuleAssembly.make(output: self)
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
        serverConfigurationCoordinatorAssembly.make()
    }
}
