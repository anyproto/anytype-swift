import Foundation
import UIKit

final class RelationValueCoordinatorAssembly: RelationValueCoordinatorAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let modulesDI: ModulesDIProtocol
    
    init(serviceLocator: ServiceLocator, modulesDI: ModulesDIProtocol) {
        self.serviceLocator = serviceLocator
        self.modulesDI = modulesDI
    }
    
    // MARK: - RelationValueCoordinatorAssemblyProtocol
    
    func make(viewController: UIViewController) -> RelationValueCoordinatorProtocol {
        
        let coordinator = RelationValueCoordinator(
            viewController: viewController,
            relationValueModuleAssembly: modulesDI.relationValue,
            urlOpener: URLOpener(viewController: viewController)
        )
        
        return coordinator
    }
    
}
