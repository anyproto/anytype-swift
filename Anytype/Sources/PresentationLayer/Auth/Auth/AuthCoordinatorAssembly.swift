import SwiftUI

protocol AuthCoordinatorAssemblyProtocol {
    @MainActor
    func make() -> AuthCoordinatorProtocol
}

final class AuthCoordinatorAssembly: AuthCoordinatorAssemblyProtocol {
    
    // MARK: - DI
    
    private let coordinatorsID: CoordinatorsDIProtocol
    
    init(
        coordinatorsID: CoordinatorsDIProtocol
    ) {
        self.coordinatorsID = coordinatorsID
    }
    
    // MARK: - HomeCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> AuthCoordinatorProtocol {
        return AuthCoordinator(
            joinFlowCoordinator: coordinatorsID.joinFlow().make(),
            loginFlowCoordinator: LoginFlowCoordinator()
        )
    }
}

