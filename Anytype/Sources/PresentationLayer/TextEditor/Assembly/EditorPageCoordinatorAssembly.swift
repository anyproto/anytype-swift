import Foundation
import UIKit

protocol EditorPageCoordinatorAssemblyProtocol: AnyObject {
    func make(browserController: EditorBrowserController?) -> EditorPageCoordinatorProtocol
}

final class EditorPageCoordinatorAssembly: EditorPageCoordinatorAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let modulesDI: ModulesDIProtocol
    private let coordinatorsID: CoordinatorsDIProtocol
    
    init(serviceLocator: ServiceLocator, modulesDI: ModulesDIProtocol, coordinatorsID: CoordinatorsDIProtocol) {
        self.serviceLocator = serviceLocator
        self.modulesDI = modulesDI
        self.coordinatorsID = coordinatorsID
    }
    
    // MARK: - RelationValueCoordinatorAssemblyProtocol
    
    func make(browserController: EditorBrowserController?) -> EditorPageCoordinatorProtocol {
    
        let coordinator = EditorPageCoordinator(
            browserController: browserController,
            editorAssembly: coordinatorsID.editor(),
            alertHelper: AlertHelper(viewController: browserController)
        )
        
        return coordinator
    }
    
}
