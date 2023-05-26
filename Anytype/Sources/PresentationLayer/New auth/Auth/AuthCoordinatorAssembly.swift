import SwiftUI

protocol AuthCoordinatorAssemblyProtocol {
    @MainActor
    func make() -> AuthCoordinatorProtocol
}

final class AuthCoordinatorAssembly: AuthCoordinatorAssemblyProtocol {
    
    // MARK: - DI
    
    private let modulesDI: ModulesDIProtocol
    private let coordinatorsID: CoordinatorsDIProtocol
    
    init(modulesDI: ModulesDIProtocol, coordinatorsID: CoordinatorsDIProtocol) {
        self.modulesDI = modulesDI
        self.coordinatorsID = coordinatorsID
    }
    
    // MARK: - HomeWidgetsCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> AuthCoordinatorProtocol {
        return AuthCoordinator(
            authModuleAssembly: modulesDI.authorization(),
            joinFlowCoordinator: coordinatorsID.joinFlow().make()
        )
    }
}

