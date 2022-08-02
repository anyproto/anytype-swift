import Foundation
import UIKit

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
    
    func make(viewController: UIViewController) -> TemplatesCoordinator {
        return TemplatesCoordinator(
            rootViewController: viewController,
            keyboardHeightListener: .init(),
            searchService: serviceLocator.searchService(),
            editorPageAssembly: coordinatorsDI.editor
        )
    }
}
