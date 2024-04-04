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
            objectActionsService: serviceLocator.objectActionsService(),
            defaultObjectService: serviceLocator.defaultObjectCreationService(),
            blockService: serviceLocator.blockService(),
            pasteboardBlockService: serviceLocator.pasteboardBlockService(),
            typeProvider: serviceLocator.objectTypeProvider(),
            appActionsStorage: serviceLocator.appActionStorage(),
            spaceSwitchCoordinatorAssembly: coordinatorsID.spaceSwitch(),
            spaceSettingsCoordinatorAssembly: coordinatorsID.spaceSettings(),
            editorCoordinatorAssembly: coordinatorsID.editor(),
            homeBottomNavigationPanelModuleAssembly: modulesDI.homeBottomNavigationPanel(),
            objectTypeSearchModuleAssembly: modulesDI.objectTypeSearch(),
            workspacesStorage: serviceLocator.workspaceStorage(),
            documentsProvider: serviceLocator.documentsProvider,
            setObjectCreationCoordinatorAssembly: coordinatorsID.setObjectCreation(),
            sharingTipCoordinator: coordinatorsID.sharingTip(),
            typeSearchCoordinatorAssembly: coordinatorsID.typeSearchForNewObject()
        )
    }
}

