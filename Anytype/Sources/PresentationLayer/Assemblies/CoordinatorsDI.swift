import Foundation
import UIKit

final class CoordinatorsDI: CoordinatorsDIProtocol {
    
    private let serviceLocator: ServiceLocator
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, modulesDI: ModulesDIProtocol, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - CoordinatorsDIProtocol
    
    func relationValue() -> RelationValueCoordinatorAssemblyProtocol {
        return RelationValueCoordinatorAssembly(
            serviceLocator: serviceLocator,
            modulesDI: modulesDI,
            uiHelpersDI: uiHelpersDI
        )
    }
    
    func templates() -> TemplatesCoordinatorAssemblyProtocol {
        return TemplatesCoordinatorAssembly(serviceLocator: serviceLocator, coordinatorsDI: self)
    }
    
    func editorPage() -> EditorPageCoordinatorAssemblyProtocol {
        return EditorPageCoordinatorAssembly(
            serviceLocator: serviceLocator,
            modulesDI: modulesDI,
            coordinatorsID: self
        )
    }
    
    func linkToObject() -> LinkToObjectCoordinatorAssemblyProtocol {
        return LinkToObjectCoordinatorAssembly(
            serviceLocator: serviceLocator,
            modulesDI: modulesDI,
            coordinatorsID: self,
            uiHelopersDI: uiHelpersDI
        )
    }
    
    func objectSettings() -> ObjectSettingsCoordinatorAssemblyProtocol {
        return ObjectSettingsCoordinatorAssembly(modulesDI: modulesDI, uiHelpersDI: uiHelpersDI, coordinatorsDI: self)
    }
    
    func addNewRelation() -> AddNewRelationCoordinatorAssemblyProtocol {
        return AddNewRelationCoordinatorAssembly(uiHelpersDI: uiHelpersDI, modulesDI: modulesDI)
    }
    
    @MainActor
    func homeWidgets() -> HomeWidgetsCoordinatorAssemblyProtocol {
        return HomeWidgetsCoordinatorAssembly(
            coordinatorsID: self,
            modulesDI: modulesDI,
            serviceLocator: serviceLocator,
            uiHelpersDI: uiHelpersDI
        )
    }
    
    func createWidget() -> CreateWidgetCoordinatorAssemblyProtocol {
        return CreateWidgetCoordinatorAssembly(
            modulesDI: modulesDI,
            serviceLocator: serviceLocator,
            uiHelpersDI: uiHelpersDI
        )
    }
    
    func browser() -> EditorBrowserAssembly {
        return EditorBrowserAssembly(coordinatorsDI: self, serviceLocator: serviceLocator)
    }
    
    func editor() -> EditorAssembly {
        return EditorAssembly(serviceLocator: serviceLocator, coordinatorsDI: self, modulesDI: modulesDI, uiHelpersDI: uiHelpersDI)
    }
    
    func homeViewAssemby() -> HomeViewAssembly {
        return HomeViewAssembly(coordinatorsDI: self, modulesDI: modulesDI)
    }
    
    @MainActor
    func application() -> ApplicationCoordinator {
        return ApplicationCoordinator(
            windowManager: windowManager(),
            authService: serviceLocator.authService(),
            accountEventHandler: serviceLocator.accountEventHandler()
        )
    }
    
    @MainActor
    func windowManager() -> WindowManager {
        WindowManager(
            viewControllerProvider: uiHelpersDI.viewControllerProvider(),
            homeViewAssembly: homeViewAssemby(),
            homeWidgetsCoordinatorAssembly: homeWidgets()
        )
    }
}
