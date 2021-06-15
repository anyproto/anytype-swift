import UIKit

final class BlockMenuItemsViewControllerCoordinatorImp: BlockMenuItemsViewControllerCoordinator {
    
    private let actionsHandler: SlashMenuActionsHandler
    private let dismissHandler: () -> Void
    
    init(actionsHandler: SlashMenuActionsHandler, dismissHandler: @escaping () -> Void) {
        self.actionsHandler = actionsHandler
        self.dismissHandler = dismissHandler
    }
    
    func didSelect(_ menuItem: BlockActionMenuItem, in controler: UIViewController) {
        switch menuItem {
        case let .menu(type, children):
            guard !children.isEmpty else { return }
            let coordinator = BlockMenuItemsViewControllerCoordinatorImp(
                actionsHandler: actionsHandler,
                dismissHandler: dismissHandler
            )
            let childController = BlockMenuItemsViewController(
                coordinator: coordinator,
                items: children
            )
            childController.title = type.title
            controler.navigationController?.pushViewController(childController, animated: true)
        case let .action(action):
            self.actionsHandler.handle(action: action)
            self.dismissHandler()
        case .sectionDivider:
            break
        }
    }
}
