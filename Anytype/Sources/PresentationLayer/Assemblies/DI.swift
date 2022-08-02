import Foundation

final class DI: DIProtocol {
    
    lazy var coordinatorsDI: CoordinatorsDIProtocol = {
        return CoordinatorsDI(serviceLocator: ServiceLocator.shared, modulesDI: modulesDI)
    }()
    
    lazy var modulesDI: ModulesDIProtocol = {
        return ModulesDI()
    }()
}
