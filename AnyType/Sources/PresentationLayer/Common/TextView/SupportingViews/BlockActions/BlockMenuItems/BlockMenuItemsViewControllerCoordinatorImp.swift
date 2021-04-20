
import UIKit

struct BlockMenuItemsViewControllerCoordinatorImp: BlockMenuItemsViewControllerCoordinator {
    
    func didSelect(_ menuItem: BlockActionMenuItem, in controler: UIViewController) {
        switch menuItem {
        case let .menu(type, children):
            guard !children.isEmpty else { return }
            let coordinator = BlockMenuItemsViewControllerCoordinatorImp()
            let childController = BlockMenuItemsViewController(coordinator: coordinator,
                                                               items: children)
            childController.title = type.title
            controler.navigationController?.pushViewController(childController, animated: true)
        case .action:
            break
        case .sectionDivider:
            break
        }
    }
}
