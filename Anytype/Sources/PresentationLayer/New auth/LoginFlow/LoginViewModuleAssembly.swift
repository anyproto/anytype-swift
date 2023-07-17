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
                authService: serviceLocator.authService(),
                seedService: serviceLocator.seedService(),
                localAuthService: serviceLocator.localAuthService(),
                cameraPermissionVerifier: serviceLocator.cameraPermissionVerifier(),
                output: output
            )
        ).eraseToAnyView()
    }
}
