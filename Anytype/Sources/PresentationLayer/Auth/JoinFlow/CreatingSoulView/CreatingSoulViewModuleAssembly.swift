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
                accountManager: self.serviceLocator.accountManager(),
                subscriptionService: self.serviceLocator.singleObjectSubscriptionService(),
                authService: self.serviceLocator.authService(),
                seedService: self.serviceLocator.seedService(),
                usecaseService: self.serviceLocator.usecaseService()
            )
        ).eraseToAnyView()
    }
}
