import Foundation
import UIKit

protocol RelationValueCoordinatorAssemblyProtocol: AnyObject {
    func make(viewController: UIViewController) -> RelationValueCoordinatorProtocol
}

final class RelationValueCoordinatorAssembly: RelationValueCoordinatorAssemblyProtocol {
    
    private let servicesAssembly: ServicesAssemblyProtocol
    private let modulesAssembly: ModulesAssemblyProtocol
    
    init(servicesAssembly: ServicesAssemblyProtocol, modulesAssembly: ModulesAssemblyProtocol) {
        self.servicesAssembly = servicesAssembly
        self.modulesAssembly = modulesAssembly
    }
    
    // MARK: - RelationValueCoordinatorAssemblyProtocol
    
    func make(viewController: UIViewController) -> RelationValueCoordinatorProtocol {
        
        let coordinator = RelationValueCoordinator(
            viewController: viewController,
            relationValueModuleAssembly: modulesAssembly.relationValue,
            urlOpener: URLOpener(viewController: viewController)
        )
        
        return coordinator
    }
    
}
