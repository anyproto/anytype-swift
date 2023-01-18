import Foundation
import UIKit

protocol LinkToObjectCoordinatorAssemblyProtocol: AnyObject {
    func make(browserController: EditorBrowserController?) -> LinkToObjectCoordinatorProtocol
}

final class LinkToObjectCoordinatorAssembly: LinkToObjectCoordinatorAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let modulesDI: ModulesDIProtocol
    private let coordinatorsID: CoordinatorsDIProtocol
    private let uiHelopersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, modulesDI: ModulesDIProtocol, coordinatorsID: CoordinatorsDIProtocol, uiHelopersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.modulesDI = modulesDI
        self.coordinatorsID = coordinatorsID
        self.uiHelopersDI = uiHelopersDI
    }
    
    // MARK: - LinkToObjectCoordinatorAssemblyProtocol
    
    func make(browserController: EditorBrowserController?) -> LinkToObjectCoordinatorProtocol {
        
        let coordinator = LinkToObjectCoordinator(
            navigationContext: uiHelopersDI.commonNavigationContext,
            pageService: serviceLocator.pageService(),
            urlOpener: URLOpener(viewController: browserController),
            editorPageCoordinator: coordinatorsID.editorPage.make(
                browserController: browserController
            ),
            searchService: serviceLocator.searchService()
        )
        
        return coordinator
    }
}
