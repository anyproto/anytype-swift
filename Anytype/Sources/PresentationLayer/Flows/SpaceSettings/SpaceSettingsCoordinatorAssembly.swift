import Foundation
import SwiftUI

protocol SpaceSettingsCoordinatorAssemblyProtocol: AnyObject {
    @MainActor
    func make() -> AnyView
}

final class SpaceSettingsCoordinatorAssembly: SpaceSettingsCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(
        modulesDI: ModulesDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol,
        coordinatorsDI: CoordinatorsDIProtocol
    ) {
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - SpaceSettingsCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> AnyView {
        return SpaceSettingsCoordinatorView(
            model: SpaceSettingsCoordinatorViewModel(
                navigationContext: self.uiHelpersDI.commonNavigationContext(),
                urlOpener: self.uiHelpersDI.urlOpener()
            )
        ).eraseToAnyView()
    }

}
