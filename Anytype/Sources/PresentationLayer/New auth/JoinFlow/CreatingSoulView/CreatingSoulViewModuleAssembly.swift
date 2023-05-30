import SwiftUI

protocol CreatingSoulViewModuleAssemblyProtocol {
    @MainActor
    func make(state: JoinFlowState, output: JoinFlowStepOutput?) -> AnyView
}

final class CreatingSoulViewModuleAssembly: CreatingSoulViewModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - CreatingSoulViewModuleAssemblyProtocol
    
    @MainActor
    func make(state: JoinFlowState, output: JoinFlowStepOutput?) -> AnyView {
        return CreatingSoulView(
            model: CreatingSoulViewModel(
                state: state,
                output: output,
                accountManager: serviceLocator.accountManager(),
                subscriptionService: serviceLocator.singleObjectSubscriptionService()
            )
        ).eraseToAnyView()
    }
}
