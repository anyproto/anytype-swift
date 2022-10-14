import Foundation
import UIKit

protocol LinkInTextCoordinatorAssemblyProtocol: AnyObject {
    func make(
        rootController: EditorBrowserController?,
        viewController: UIViewController,
        blockActionHandler: BlockActionHandlerProtocol
    ) -> LinkInTextCoordinatorProtocol
}

final class LinkInTextCoordinatorAssembly: LinkInTextCoordinatorAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let modulesDI: ModulesDIProtocol
    private let coordinatorsID: CoordinatorsDIProtocol
    
    init(serviceLocator: ServiceLocator, modulesDI: ModulesDIProtocol, coordinatorsID: CoordinatorsDIProtocol) {
        self.serviceLocator = serviceLocator
        self.modulesDI = modulesDI
        self.coordinatorsID = coordinatorsID
    }
    
    // MARK: - LinkInTextCoordinatorAssemblyProtocol
    
    func make(
        rootController: EditorBrowserController?,
        viewController: UIViewController,
        blockActionHandler: BlockActionHandlerProtocol
    ) -> LinkInTextCoordinatorProtocol {
        
        let coordinator = LinkInTextCoordinator(
            rootViewController: viewController,
            actionHandler: blockActionHandler,
            pageService: serviceLocator.pageService(),
            urlOpener: URLOpener(viewController: viewController),
            editorPageCoordinator: coordinatorsID.editorPage.make(
                rootController: rootController,
                viewController: viewController
            )
        )
        
        return coordinator
    }
}
