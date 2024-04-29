import Foundation
import UIKit
import AnytypeCore

final class DI: DIProtocol {
    
    private let viewControllerProvider: ViewControllerProviderProtocol
    
    init(viewControllerProvider: ViewControllerProviderProtocol) {
        self.viewControllerProvider = viewControllerProvider
    }
    
    // MARK: - DIProtocol
    
    lazy var coordinatorsDI: CoordinatorsDIProtocol = {
        return CoordinatorsDI(serviceLocator: serviceLocator, modulesDI: modulesDI, uiHelpersDI: uihelpersDI)
    }()
    
    lazy var modulesDI: ModulesDIProtocol = {
        return ModulesDI(uiHelpersDI: uihelpersDI, widgetsSubmoduleDI: widgetsSubmoduleDI)
    }()
    
    lazy var uihelpersDI: UIHelpersDIProtocol = {
        return UIHelpersDI(viewControllerProvider: viewControllerProvider, serviceLocator: serviceLocator)
    }()
    
    var serviceLocator: ServiceLocator {
        return ServiceLocator.shared
    }
    
    lazy var widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol = {
        return WidgetsSubmoduleDI(serviceLocator: serviceLocator, uiHelpersDI: uihelpersDI)
    }()
}


extension DI {
    static var preview: DIProtocol {
        if !AppContext.isPreview {
            anytypeAssertionFailure("Preview DI available only in debug")
        }
        return DI(viewControllerProvider: ViewControllerProvider(sceneWindow: UIWindow()))
    }
}
