import SwiftUI

protocol SoulViewModuleAssemblyProtocol {
    @MainActor
    func make(state: JoinFlowState, output: JoinFlowStepOutput?) -> AnyView
}

final class SoulViewModuleAssembly: SoulViewModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SoulViewModuleAssemblyProtocol
    
    @MainActor
    func make(state: JoinFlowState, output: JoinFlowStepOutput?) -> AnyView {
        return SoulView(
            model: SoulViewModel(
                state: state,
                output: output,
                accountManager: serviceLocator.accountManager(),
                objectActionsService: serviceLocator.objectActionsService()
            )
        ).eraseToAnyView()
    }
}
