
import UIKit

final class BlockMenuItemsViewControllerCoordinatorImp: BlockMenuItemsViewControllerCoordinator {
    
    private let actionsHandler: BlockMenuActionsHandler
    
    init(actionsHandler: BlockMenuActionsHandler) {
        self.actionsHandler = actionsHandler
    }
    
    func didSelect(_ menuItem: BlockActionMenuItem, in controler: UIViewController) {
        switch menuItem {
        case let .menu(type, children):
            guard !children.isEmpty else { return }
            let coordinator = BlockMenuItemsViewControllerCoordinatorImp(actionsHandler: self.actionsHandler)
            let childController = BlockMenuItemsViewController(coordinator: coordinator,
                                                               items: children)
            childController.title = type.title
            controler.navigationController?.pushViewController(childController, animated: true)
        case let .action(action):
            self.actionsHandler.handle(action: action)
        case .sectionDivider:
            break
        }
    }
}
