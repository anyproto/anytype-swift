import Foundation
import UIKit

protocol TemplatesCoordinatorAssemblyProtocol: AnyObject {
    func make(viewController: UIViewController) -> TemplatesCoordinator
}

final class TemplatesCoordinatorAssembly: TemplatesCoordinatorAssemblyProtocol {
    
    private let servicesAssembly: ServicesAssemblyProtocol
    private let coordinatorsAssembly: CoordinatorsAssemblyProtocol
    
    init(
        servicesAssembly: ServicesAssemblyProtocol,
        coordinatorsAssembly: CoordinatorsAssemblyProtocol
    ) {
        self.servicesAssembly = servicesAssembly
        self.coordinatorsAssembly = coordinatorsAssembly
    }
    
    // MARK: - TemplatesCoordinatorAssemblyProtocol
    
    func make(viewController: UIViewController) -> TemplatesCoordinator {
        return TemplatesCoordinator(
            rootViewController: viewController,
            keyboardHeightListener: .init(),
            searchService: servicesAssembly.search,
            editorPageAssembly: coordinatorsAssembly.editor
        )
    }
}
