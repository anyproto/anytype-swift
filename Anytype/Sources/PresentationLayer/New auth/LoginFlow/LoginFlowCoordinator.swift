import SwiftUI

@MainActor
protocol LoginFlowCoordinatorProtocol {
    func startFlow() -> AnyView
}

@MainActor
final class LoginFlowCoordinator: LoginFlowCoordinatorProtocol, LoginFlowOutput {
    
    // MARK: - DI
    
    private let loginViewModuleAssembly: LoginViewModuleAssemblyProtocol
    
    init(loginViewModuleAssembly: LoginViewModuleAssemblyProtocol) {
        self.loginViewModuleAssembly = loginViewModuleAssembly
    }
    
    // MARK: - LoginFlowCoordinatorProtocol
    
    func startFlow() -> AnyView {
        loginViewModuleAssembly.make()
    }
}
