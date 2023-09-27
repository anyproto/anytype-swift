import SwiftUI

protocol LoginFlowCoordinatorAssemblyProtocol {
    @MainActor
    func make() -> LoginFlowCoordinatorProtocol
}

final class LoginFlowCoordinatorAssembly: LoginFlowCoordinatorAssemblyProtocol {
    
    // MARK: - DI
    
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(modulesDI: ModulesDIProtocol, uiHelpersDI: UIHelpersDIProtocol) {
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - LoginFlowCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> LoginFlowCoordinatorProtocol {
        return LoginFlowCoordinator(
            loginViewModuleAssembly: modulesDI.login()
        )
    }
}

