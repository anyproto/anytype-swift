import Foundation
import SwiftUI

@MainActor
protocol HomeWidgetsCoordinatorAssemblyProtocol {
    func make() -> HomeWidgetsCoordinatorProtocol
}

@MainActor
final class HomeWidgetsCoordinatorAssembly: HomeWidgetsCoordinatorAssemblyProtocol {
    
    private let coordinatorsID: CoordinatorsDIProtocol
    private let modulesDI: ModulesDIProtocol
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(
        coordinatorsID: CoordinatorsDIProtocol,
        modulesDI: ModulesDIProtocol,
        serviceLocator: ServiceLocator,
        uiHelpersDI: UIHelpersDIProtocol
    ) {
        self.coordinatorsID = coordinatorsID
        self.modulesDI = modulesDI
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - HomeWidgetsCoordinatorAssemblyProtocol
    
    func make() -> HomeWidgetsCoordinatorProtocol {
        return HomeWidgetsCoordinator(
            homeWidgetsModuleAssembly: modulesDI.homeWidgets,
            accountManager: serviceLocator.accountManager(),
            navigationContext: uiHelpersDI.commonNavigationContext,
            windowManager: coordinatorsID.windowManager
        )
    }
}

