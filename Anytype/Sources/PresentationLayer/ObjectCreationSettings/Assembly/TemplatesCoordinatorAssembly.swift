import Foundation
import UIKit

protocol TemplatesCoordinatorAssemblyProtocol: AnyObject {
    @MainActor
    func make(viewController: UIViewController) -> TemplatesCoordinatorProtocol
}

final class TemplatesCoordinatorAssembly: TemplatesCoordinatorAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(
        serviceLocator: ServiceLocator,
        coordinatorsDI: CoordinatorsDIProtocol
    ) {
        self.serviceLocator = serviceLocator
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - TemplatesCoordinatorAssemblyProtocol
    
    @MainActor
    func make(viewController: UIViewController) -> TemplatesCoordinatorProtocol {
        return TemplatesCoordinator(
            rootViewController: viewController,
            editorPageAssembly: coordinatorsDI.editor(), 
            objectSettingCoordinator: coordinatorsDI.objectSettings().make(browserController: nil)
        )
    }
}
