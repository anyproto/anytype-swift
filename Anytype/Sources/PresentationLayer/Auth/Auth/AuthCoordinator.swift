import SwiftUI

@MainActor
protocol AuthCoordinatorProtocol {
    func startFlow() -> AnyView
}

@MainActor
final class AuthCoordinator: AuthCoordinatorProtocol, AuthViewModelOutput {
    
    // MARK: - DI
    
    private let authModuleAssembly: AuthModuleAssemblyProtocol
    private let debugMenuModuleAssembly: DebugMenuModuleAssemblyProtocol
    private let joinFlowCoordinator: JoinFlowCoordinatorProtocol
    private let loginFlowCoordinator: LoginFlowCoordinatorProtocol
    private let urlOpener: URLOpenerProtocol
    
    init(
        authModuleAssembly: AuthModuleAssemblyProtocol,
        debugMenuModuleAssembly: DebugMenuModuleAssemblyProtocol,
        joinFlowCoordinator: JoinFlowCoordinatorProtocol,
        loginFlowCoordinator: LoginFlowCoordinatorProtocol,
        urlOpener: URLOpenerProtocol
    ) {
        self.authModuleAssembly = authModuleAssembly
        self.debugMenuModuleAssembly = debugMenuModuleAssembly
        self.joinFlowCoordinator = joinFlowCoordinator
        self.loginFlowCoordinator = loginFlowCoordinator
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
    
    func onDebugMenuAction() -> AnyView {
        debugMenuModuleAssembly.make()
    }
}
