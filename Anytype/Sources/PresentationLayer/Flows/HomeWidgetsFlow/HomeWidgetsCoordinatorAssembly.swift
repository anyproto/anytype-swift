import Foundation
import SwiftUI

protocol HomeWidgetsCoordinatorAssemblyProtocol {
    @MainActor
    func make() -> AnyView
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
    func make() -> AnyView {
        return HomeWidgetsCoordinatorView(model: self.makeModel()).eraseToAnyView()
    }
    
    // MARK: - Private func
    
    @MainActor
    private func makeModel() -> HomeWidgetsCoordinatorViewModel {
        HomeWidgetsCoordinatorViewModel(
            homeWidgetsModuleAssembly: modulesDI.homeWidgets(),
            activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage(),
            navigationContext: uiHelpersDI.commonNavigationContext(),
            createWidgetCoordinatorAssembly: coordinatorsID.createWidget(),
            searchModuleAssembly: modulesDI.search(),
            newSearchModuleAssembly: modulesDI.newSearch(),
            dashboardService: serviceLocator.dashboardService(),
            appActionsStorage: serviceLocator.appActionStorage(),
            widgetTypeModuleAssembly: modulesDI.widgetType(),
            spaceSwitchCoordinatorAssembly: coordinatorsID.spaceSwitch(),
            spaceSettingsCoordinatorAssembly: coordinatorsID.spaceSettings(),
            shareCoordinatorAssembly: coordinatorsID.share(),
            editorCoordinatorAssembly: coordinatorsID.editor(),
            homeBottomNavigationPanelModuleAssembly: modulesDI.homeBottomNavigationPanel(),
            objectTypeSearchModuleAssembly: modulesDI.objectTypeSearch(),
            workspacesStorage: serviceLocator.workspaceStorage(),
            documentsProvider: serviceLocator.documentsProvider,
            setObjectCreationCoordinatorAssembly: coordinatorsID.setObjectCreation(),
            sharingTipCoordinator: coordinatorsID.sharingTip(),
            notificationCoordinator: coordinatorsID.notificationCoordinator()
        )
    }
}

