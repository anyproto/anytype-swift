import UIKit

final class SlashMenuItemsViewControllerCoordinatorImp: SlashMenuItemsViewControllerCoordinator {
    
    private let actionsHandler: SlashMenuActionsHandler
    private let dismissHandler: (() -> Void)?
    
    init(actionsHandler: SlashMenuActionsHandler, dismissHandler: (() -> Void)?) {
        self.actionsHandler = actionsHandler
        self.dismissHandler = dismissHandler
    }
    
    func didSelect(_ menuItem: BlockActionMenuItem, in controler: UIViewController) {
        switch menuItem {
        case let .menu(type, children):
            guard !children.isEmpty else { return }
            let coordinator = SlashMenuItemsViewControllerCoordinatorImp(
                actionsHandler: actionsHandler,
                dismissHandler: dismissHandler
            )
            let childController = SlashMenuItemsViewController(
                coordinator: coordinator,
                items: children
            )
            childController.title = type.title
            controler.navigationController?.pushViewController(childController, animated: true)
        case let .action(action):
            actionsHandler.handle(action: action)
            dismissHandler?()
        case .sectionDivider:
            break
        }
    }
}
