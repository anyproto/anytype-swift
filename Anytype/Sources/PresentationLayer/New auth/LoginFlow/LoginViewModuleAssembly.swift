import SwiftUI

protocol LoginViewModuleAssemblyProtocol {
    @MainActor
    func make(output: LoginFlowOutput) -> AnyView
}

final class LoginViewModuleAssembly: LoginViewModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - LoginViewModuleAssemblyProtocol
    
    @MainActor
    func make(output: LoginFlowOutput) -> AnyView {
        return LoginView(
            model: LoginViewModel(
                authService: self.serviceLocator.authService(),
                seedService: self.serviceLocator.seedService(),
                localAuthService: self.serviceLocator.localAuthService(),
                cameraPermissionVerifier: self.serviceLocator.cameraPermissionVerifier(),
                accountEventHandler: self.serviceLocator.accountEventHandler(),
                applicationStateService: self.serviceLocator.applicationStateService(),
                output: output
            )
        ).eraseToAnyView()
    }
}
