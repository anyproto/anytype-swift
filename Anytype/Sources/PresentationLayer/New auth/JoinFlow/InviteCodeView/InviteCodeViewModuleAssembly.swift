import SwiftUI

protocol InviteCodeViewModuleAssemblyProtocol {
    @MainActor
    func make(state: JoinFlowState, output: JoinFlowStepOutput?) -> AnyView
}

final class InviteCodeViewModuleAssembly: InviteCodeViewModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - InviteCodeViewModuleAssemblyProtocol
    
    @MainActor
    func make(state: JoinFlowState, output: JoinFlowStepOutput?) -> AnyView {
        return JoinFlowInputView(
            model: InviteCodeViewModel(
                state: state,
                output: output,
                authService: serviceLocator.authService(),
                seedService: serviceLocator.seedService()
            )
        ).eraseToAnyView()
    }
}
