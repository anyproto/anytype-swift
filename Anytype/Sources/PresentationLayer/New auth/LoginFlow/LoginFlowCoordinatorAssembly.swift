import SwiftUI

protocol LoginFlowCoordinatorAssemblyProtocol {
    @MainActor
    func make() -> LoginFlowCoordinatorProtocol
}

final class LoginFlowCoordinatorAssembly: LoginFlowCoordinatorAssemblyProtocol {
    
    // MARK: - DI
    
    private let modulesDI: ModulesDIProtocol
    
    init(modulesDI: ModulesDIProtocol) {
        self.modulesDI = modulesDI
    }
    
    // MARK: - LoginFlowCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> LoginFlowCoordinatorProtocol {
        return LoginFlowCoordinator(
            loginViewModuleAssembly: modulesDI.login()
        )
    }
}

