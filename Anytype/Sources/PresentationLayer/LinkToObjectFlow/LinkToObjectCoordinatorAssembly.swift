import Foundation
import UIKit

protocol LinkToObjectCoordinatorAssemblyProtocol: AnyObject {
    func make(output: LinkToObjectCoordinatorOutput?) -> LinkToObjectCoordinatorProtocol
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
    
    func make(output: LinkToObjectCoordinatorOutput?) -> LinkToObjectCoordinatorProtocol {
        
        let coordinator = LinkToObjectCoordinator(
            navigationContext: uiHelopersDI.commonNavigationContext(),
            defaultObjectService: serviceLocator.defaultObjectCreationService(),
            urlOpener: uiHelopersDI.urlOpener(),
            searchService: serviceLocator.searchService(),
            pasteboardHelper: serviceLocator.pasteboardHelper(),
            output: output
        )
        
        return coordinator
    }
}
