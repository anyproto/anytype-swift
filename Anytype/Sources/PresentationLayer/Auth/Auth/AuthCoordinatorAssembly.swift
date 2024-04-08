import SwiftUI

protocol AuthCoordinatorAssemblyProtocol {
    @MainActor
    func make() -> AuthCoordinatorProtocol
}

final class AuthCoordinatorAssembly: AuthCoordinatorAssemblyProtocol {
    
    // MARK: - DI
    
    private let coordinatorsID: CoordinatorsDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(
        coordinatorsID: CoordinatorsDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol
    ) {
        self.coordinatorsID = coordinatorsID
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - HomeCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> AuthCoordinatorProtocol {
        return AuthCoordinator(
            joinFlowCoordinator: coordinatorsID.joinFlow().make(),
            loginFlowCoordinator: LoginFlowCoordinator(),
            urlOpener: uiHelpersDI.urlOpener()
        )
    }
}

