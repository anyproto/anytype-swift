import SwiftUI

protocol AuthModuleAssemblyProtocol {
    @MainActor
    func make(state: JoinFlowState, output: AuthViewModelOutput?) -> AnyView
}

final class AuthModuleAssembly: AuthModuleAssemblyProtocol {
    
    private let uiHelpersDI: UIHelpersDIProtocol
    private let serviceLocator: ServiceLocator
    
    init(uiHelpersDI: UIHelpersDIProtocol, serviceLocator: ServiceLocator) {
        self.uiHelpersDI = uiHelpersDI
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - AuthModuleAssemblyProtocol
    
    @MainActor
    func make(state: JoinFlowState, output: AuthViewModelOutput?) -> AnyView {
        return AuthView(
            model: AuthViewModel(
                state: state,
                viewControllerProvider: uiHelpersDI.viewControllerProvider(),
                output: output,
                authService: serviceLocator.authService(),
                seedService: serviceLocator.seedService()
            )
        ).eraseToAnyView()
    }
}
