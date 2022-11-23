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
    
    var relationValue: RelationValueCoordinatorAssemblyProtocol {
        return RelationValueCoordinatorAssembly(
            serviceLocator: serviceLocator,
            modulesDI: modulesDI
        )
    }
    
    var templates: TemplatesCoordinatorAssemblyProtocol {
        return TemplatesCoordinatorAssembly(serviceLocator: serviceLocator, coordinatorsDI: self)
    }
    
    var editorPage: EditorPageCoordinatorAssemblyProtocol {
        return EditorPageCoordinatorAssembly(
            serviceLocator: serviceLocator,
            modulesDI: modulesDI,
            coordinatorsID: self
        )
    }
    
    var linkToObject: LinkToObjectCoordinatorAssemblyProtocol {
        return LinkToObjectCoordinatorAssembly(
            serviceLocator: serviceLocator,
            modulesDI: modulesDI,
            coordinatorsID: self,
            uiHelopersDI: uiHelpersDI
        )
    }
    
    var browser: EditorBrowserAssembly {
        return EditorBrowserAssembly(coordinatorsDI: self)
    }
    
    var editor: EditorAssembly {
        return EditorAssembly(serviceLocator: serviceLocator, coordinatorsDI: self, modulesDI: modulesDI)
    }
    
    var homeViewAssemby: HomeViewAssembly {
        return HomeViewAssembly(coordinatorsDI: self)
    }
    
    var application: ApplicationCoordinator {
        return ApplicationCoordinator(
            windowManager: windowManager,
            authService: serviceLocator.authService()
        )
    }
    
    var windowManager: WindowManager {
        WindowManager(
            viewControllerProvider: uiHelpersDI.viewControllerProvider,
            homeViewAssembly: homeViewAssemby
        )
    }

}
