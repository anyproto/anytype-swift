import Foundation
import UIKit

protocol LinkToObjectCoordinatorAssemblyProtocol: AnyObject {
    func make(
        rootController: EditorBrowserController?,
        viewController: UIViewController
    ) -> LinkToObjectCoordinatorProtocol
}

final class LinkToObjectCoordinatorAssembly: LinkToObjectCoordinatorAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let modulesDI: ModulesDIProtocol
    private let coordinatorsID: CoordinatorsDIProtocol
    
    init(serviceLocator: ServiceLocator, modulesDI: ModulesDIProtocol, coordinatorsID: CoordinatorsDIProtocol) {
        self.serviceLocator = serviceLocator
        self.modulesDI = modulesDI
        self.coordinatorsID = coordinatorsID
    }
    
    // MARK: - LinkToObjectCoordinatorAssemblyProtocol
    
    func make(
        rootController: EditorBrowserController?,
        viewController: UIViewController
    ) -> LinkToObjectCoordinatorProtocol {
        
        let coordinator = LinkToObjectCoordinator(
            rootViewController: viewController,
            pageService: serviceLocator.pageService(),
            urlOpener: URLOpener(viewController: viewController),
            editorPageCoordinator: coordinatorsID.editorPage.make(
                rootController: rootController,
                viewController: viewController
            ),
            searchService: serviceLocator.searchService()
        )
        
        return coordinator
    }
}
