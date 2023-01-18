import Foundation
import UIKit

final class DI: DIProtocol {
    
    private let viewControllerProvider: ViewControllerProviderProtocol
    
    init(viewControllerProvider: ViewControllerProviderProtocol) {
        self.viewControllerProvider = viewControllerProvider
    }
    
    lazy var coordinatorsDI: CoordinatorsDIProtocol = {
        return CoordinatorsDI(serviceLocator: serviceLocator, modulesDI: modulesDI, uiHelpersDI: uihelpersDI)
    }()
    
    lazy var modulesDI: ModulesDIProtocol = {
        return ModulesDI(serviceLocator: serviceLocator, uiHelpersDI: uihelpersDI)
    }()
    
    lazy var uihelpersDI: UIHelpersDIProtocol = {
       return UIHelpersDI(viewControllerProvider: viewControllerProvider)
    }()
    
    var serviceLocator: ServiceLocator {
        return ServiceLocator.shared
    }
}


extension DI {
    static func makeForPreview() -> DIProtocol {
        return DI(viewControllerProvider: ViewControllerProvider(sceneWindow: UIWindow()))
    }
}
