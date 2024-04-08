import SwiftUI

protocol JoinFlowCoordinatorAssemblyProtocol {
    @MainActor
    func make() -> JoinFlowCoordinatorProtocol
}

final class JoinFlowCoordinatorAssembly: JoinFlowCoordinatorAssemblyProtocol {
    
    // MARK: - DI
    
    private let modulesDI: ModulesDIProtocol
    
    init(modulesDI: ModulesDIProtocol) {
        self.modulesDI = modulesDI
    }
    
    // MARK: - JoinFlowCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> JoinFlowCoordinatorProtocol {
        return JoinFlowCoordinator(keyViewModuleAssembly: modulesDI.authKey())
    }
}

