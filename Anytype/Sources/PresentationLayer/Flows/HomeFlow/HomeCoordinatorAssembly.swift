import Foundation
import SwiftUI

protocol HomeCoordinatorAssemblyProtocol {
    @MainActor
    func make() -> AnyView
}

final class HomeCoordinatorAssembly: HomeCoordinatorAssemblyProtocol {
    
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
    
    // MARK: - HomeCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> AnyView {
        return HomeCoordinatorView(model: self.makeModel()).eraseToAnyView()
    }
    
    // MARK: - Private func
    
    @MainActor
    private func makeModel() -> HomeCoordinatorViewModel {
        HomeCoordinatorViewModel(
            homeWidgetsModuleAssembly: modulesDI.homeWidgets(),
            activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage(),
            navigationContext: uiHelpersDI.commonNavigationContext(),
            createWidgetCoordinatorAssembly: coordinatorsID.createWidget(),
            searchModuleAssembly: modulesDI.search(),
            newSearchModuleAssembly: modulesDI.newSearch(),
            objectActionsService: serviceLocator.objectActionsService(),
            defaultObjectService: serviceLocator.defaultObjectCreationService(),
            typeProvider: serviceLocator.objectTypeProvider(),
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
            galleryInstallationCoordinatorAssembly: coordinatorsID.galleryInstallation(),
            notificationCoordinator: coordinatorsID.notificationCoordinator()
        )
    }
}

