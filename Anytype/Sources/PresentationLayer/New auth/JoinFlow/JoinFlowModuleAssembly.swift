import SwiftUI

protocol JoinFlowModuleAssemblyProtocol {
    @MainActor
    func make(output: JoinFlowOutput?) -> AnyView
}

final class JoinFlowModuleAssembly: JoinFlowModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - JoinModuleAssemblyProtocol
    
    @MainActor
    func make(output: JoinFlowOutput?) -> AnyView {
        return JoinFlowView(
            model: JoinFlowViewModel(
                output: output,
                applicationStateService: serviceLocator.applicationStateService()
            )
        )
        .eraseToAnyView()
    }
}
