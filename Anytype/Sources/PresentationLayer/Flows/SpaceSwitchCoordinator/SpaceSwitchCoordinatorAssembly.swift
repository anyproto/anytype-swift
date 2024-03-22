import Foundation
import SwiftUI

protocol SpaceSwitchCoordinatorAssemblyProtocol: AnyObject {
    @MainActor
    func make() -> AnyView
}

final class SpaceSwitchCoordinatorAssembly: SpaceSwitchCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(
        modulesDI: ModulesDIProtocol,
        coordinatorsDI: CoordinatorsDIProtocol
    ) {
        self.modulesDI = modulesDI
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - SpaceSwitchCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> AnyView {
        return SpaceSwitchCoordinatorView(
            model: SpaceSwitchCoordinatorViewModel(
                settingsCoordinator: self.coordinatorsDI.settings().make()
            )
        ).eraseToAnyView()
    }

}
