import Foundation
import UIKit

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
        return ModulesDI(serviceLocator: serviceLocator, uiHelpersDI: uihelpersDI, widgetsDI: widgetsDI)
    }()
    
    lazy var uihelpersDI: UIHelpersDIProtocol = {
       return UIHelpersDI(viewControllerProvider: viewControllerProvider)
    }()
    
    var serviceLocator: ServiceLocator {
        return ServiceLocator.shared
    }
    
    lazy var widgetsDI: WidgetsDIProtocol = {
        return WidgetsDI(serviceLocator: serviceLocator, uiHelpersDI: uihelpersDI)
    }()
}


extension DI {
    static func makeForPreview() -> DIProtocol {
        return DI(viewControllerProvider: ViewControllerProvider(sceneWindow: UIWindow()))
    }
}
