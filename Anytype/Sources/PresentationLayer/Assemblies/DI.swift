import Foundation
import UIKit
import AnytypeCore

final class DI: DIProtocol {
    
    // MARK: - DIProtocol
    
    lazy var coordinatorsDI: CoordinatorsDIProtocol = {
        return CoordinatorsDI(serviceLocator: serviceLocator, modulesDI: modulesDI)
    }()
    
    lazy var modulesDI: ModulesDIProtocol = {
        return ModulesDI(widgetsSubmoduleDI: widgetsSubmoduleDI)
    }()
    
    lazy var serviceLocator: ServiceLocator = {
        return ServiceLocator()
    }()
    
    lazy var widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol = {
        return WidgetsSubmoduleDI(serviceLocator: serviceLocator)
    }()
}


extension DI {
    static var preview: DIProtocol {
        if !AppContext.isPreview {
            anytypeAssertionFailure("Preview DI available only in debug")
        }
        return DI()
    }
}
