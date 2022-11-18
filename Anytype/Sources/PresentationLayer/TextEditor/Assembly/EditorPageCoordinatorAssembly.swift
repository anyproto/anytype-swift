import Foundation
import UIKit

protocol EditorPageCoordinatorAssemblyProtocol: AnyObject {
    func make(
        rootController: EditorBrowserController?,
        viewController: UIViewController?
    ) -> EditorPageCoordinatorProtocol
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
    
    func make(
        rootController: EditorBrowserController?,
        viewController: UIViewController?
    ) -> EditorPageCoordinatorProtocol {
    
        let coordinator = EditorPageCoordinator(
            rootController: rootController,
            viewController: viewController,
            editorAssembly: coordinatorsID.editor,
            alertHelper: AlertHelper(viewController: viewController)
        )
        
        return coordinator
    }
    
}
