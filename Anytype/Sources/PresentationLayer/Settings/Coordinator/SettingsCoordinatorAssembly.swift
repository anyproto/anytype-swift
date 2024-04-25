import Foundation
import SwiftUI

protocol SettingsCoordinatorAssemblyProtocol {
    @MainActor
    func make() -> AnyView
}

final class SettingsCoordinatorAssembly: SettingsCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    private let coordinatorsDI: CoordinatorsDIProtocol
    private let serviceLocator: ServiceLocator
    
    init(
        modulesDI: ModulesDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol,
        coordinatorsDI: CoordinatorsDIProtocol,
        serviceLocator: ServiceLocator
    ) {
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
        self.coordinatorsDI = coordinatorsDI
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SettingsCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> AnyView {
        return SettingsCoordinatorView(
            model: SettingsCoordinatorViewModel(
                navigationContext: self.uiHelpersDI.commonNavigationContext(),
                urlOpener: self.uiHelpersDI.urlOpener()
            )
        ).eraseToAnyView()
    }
}
