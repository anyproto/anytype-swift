import UIKit

final class SlashMenuViewControllerCoordinatorImp: SlashMenuViewControllerCoordinator {
    
    private let actionsHandler: SlashMenuActionsHandler
    private let dismissHandler: (() -> Void)?
    
    init(actionsHandler: SlashMenuActionsHandler, dismissHandler: (() -> Void)?) {
        self.actionsHandler = actionsHandler
        self.dismissHandler = dismissHandler
    }
    
    func didSelect(_ menuItem: SlashMenuCellData, in controler: UIViewController) {
        switch menuItem {
        case let .menu(type, children):
            guard !children.isEmpty else { return }
            let coordinator = SlashMenuViewControllerCoordinatorImp(
                actionsHandler: actionsHandler,
                dismissHandler: dismissHandler
            )
            let childController = SlashMenuViewController(
                coordinator: coordinator,
                cellData: children.map { .action($0) }
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
