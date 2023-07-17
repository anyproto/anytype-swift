import SwiftUI

protocol EnteringVoidModuleAssemblyProtocol {
    @MainActor
    func make(output: LoginFlowOutput) -> AnyView
}

final class EnteringVoidModuleAssembly: EnteringVoidModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - EnteringVoidModuleAssemblyProtocol
    
    @MainActor
    func make(output: LoginFlowOutput) -> AnyView {
        return EnteringVoidView(
            model: EnteringVoidViewModel(
                output: output,
                applicationStateService: self.serviceLocator.applicationStateService(),
                authService: self.serviceLocator.authService(),
                accountEventHandler: self.serviceLocator.accountEventHandler()
            )
        ).eraseToAnyView()
    }
}
