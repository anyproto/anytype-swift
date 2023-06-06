import SwiftUI

protocol AuthCoordinatorAssemblyProtocol {
    @MainActor
    func make() -> AuthCoordinatorProtocol
}

final class AuthCoordinatorAssembly: AuthCoordinatorAssemblyProtocol {
    
    // MARK: - DI
    
    private let modulesDI: ModulesDIProtocol
    private let coordinatorsID: CoordinatorsDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(
        modulesDI: ModulesDIProtocol,
        coordinatorsID: CoordinatorsDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol
    ) {
        self.modulesDI = modulesDI
        self.coordinatorsID = coordinatorsID
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - HomeWidgetsCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> AuthCoordinatorProtocol {
        return AuthCoordinator(
            authModuleAssembly: modulesDI.authorization(),
            debugMenuModuleAssembly: modulesDI.debugMenu(),
            joinFlowCoordinator: coordinatorsID.joinFlow().make(),
            urlOpener: uiHelpersDI.urlOpener()
        )
    }
}

