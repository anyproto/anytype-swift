import SwiftUI

protocol AuthModuleAssemblyProtocol {
    @MainActor
    func make(state: JoinFlowState, output: AuthViewModelOutput?) -> AnyView
}

final class AuthModuleAssembly: AuthModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - AuthModuleAssemblyProtocol
    
    @MainActor
    func make(state: JoinFlowState, output: AuthViewModelOutput?) -> AnyView {
        return AuthView(
            model: AuthViewModel(
                state: state,
                output: output,
                authService: serviceLocator.authService(),
                seedService: serviceLocator.seedService(),
                metricsService: serviceLocator.metricsService()
            )
        ).eraseToAnyView()
    }
}
