import Foundation
import SwiftUI

protocol HomeWidgetsCoordinatorAssemblyProtocol {
    @MainActor
    func make() -> HomeWidgetsCoordinatorProtocol
}

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
    
    @MainActor
    func make() -> HomeWidgetsCoordinatorProtocol {
        return HomeWidgetsCoordinator(
            homeWidgetsModuleAssembly: modulesDI.homeWidgets(),
            activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage(),
            navigationContext: uiHelpersDI.commonNavigationContext(),
            createWidgetCoordinator: coordinatorsID.createWidget().make(),
            editorBrowserCoordinator: coordinatorsID.editorBrowser().make(),
            searchModuleAssembly: modulesDI.search(),
            settingsCoordinator: coordinatorsID.settings().make(),
            newSearchModuleAssembly: modulesDI.newSearch(),
            dashboardService: serviceLocator.dashboardService(),
            dashboardAlertsAssembly: modulesDI.dashboardAlerts(),
            quickActionsStorage: serviceLocator.quickActionStorage(),
            widgetTypeModuleAssembly: modulesDI.widgetType()
        )
    }
}

