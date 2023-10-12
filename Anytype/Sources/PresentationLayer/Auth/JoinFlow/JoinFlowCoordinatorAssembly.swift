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
        return JoinFlowCoordinator(
            joinFlowModuleAssembly: modulesDI.joinFlow(),
            keyViewModuleAssembly: modulesDI.authKey(),
            keyPhraseMoreInfoViewModuleAssembly: modulesDI.authKeyMoreInfo(),
            soulViewModuleAssembly: modulesDI.authSoul()
        )
    }
}

