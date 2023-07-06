import SwiftUI

protocol VoidViewModuleAssemblyProtocol {
    @MainActor
    func make(state: JoinFlowState, output: JoinFlowStepOutput?) -> AnyView
}

final class VoidViewModuleAssembly: VoidViewModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - VoidViewModuleAssemblyProtocol
    
    @MainActor
    func make(state: JoinFlowState, output: JoinFlowStepOutput?) -> AnyView {
        return VoidView(
            model: VoidViewModel(
                state: state,
                output: output,
                authService: serviceLocator.authService(),
                seedService: serviceLocator.seedService(),
                usecaseService: serviceLocator.usecaseService()
            )
        ).eraseToAnyView()
    }
}
