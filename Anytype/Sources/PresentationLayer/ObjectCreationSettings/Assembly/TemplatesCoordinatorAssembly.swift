import Foundation
import UIKit

protocol TemplatesCoordinatorAssemblyProtocol: AnyObject {
    @MainActor
    func make(viewController: UIViewController) -> TemplatesCoordinatorProtocol
}

final class TemplatesCoordinatorAssembly: TemplatesCoordinatorAssemblyProtocol {
    
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(
        coordinatorsDI: CoordinatorsDIProtocol
    ) {
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - TemplatesCoordinatorAssemblyProtocol
    
    @MainActor
    func make(viewController: UIViewController) -> TemplatesCoordinatorProtocol {
        return TemplatesCoordinator(
            rootViewController: viewController,
            editorPageCoordinatorAssembly: coordinatorsDI.editorPage()
        )
    }
}
