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
    
    // MARK: - HomeCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> AuthCoordinatorProtocol {
        return AuthCoordinator(
            joinFlowCoordinator: coordinatorsID.joinFlow().make(),
            loginFlowCoordinator: coordinatorsID.loginFlow().make(), 
            serverConfigurationCoordinatorAssembly: coordinatorsID.serverConfiguration(),
            urlOpener: uiHelpersDI.urlOpener()
        )
    }
}

