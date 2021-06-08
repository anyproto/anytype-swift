import UIKit

final class BlockActionsView: DismissableInputAccessoryView {
    
    private weak var menuNavigationController: UINavigationController?
    private weak var menuItemsViewController: BlockMenuItemsViewController?
    private let menuItems: [BlockActionMenuItem]
    private let blockMenuActionsHandler: BlockMenuActionsHandler
    
    init(frame: CGRect,
         menuItems: [BlockActionMenuItem],
         blockMenuActionsHandler: BlockMenuActionsHandler,
         actionsMenuDismissHandler: @escaping () -> Void) {
        self.menuItems = menuItems
        self.blockMenuActionsHandler = blockMenuActionsHandler
        super.init(frame: frame,
                   dismissHandler: actionsMenuDismissHandler)
    }
    
    private func setup(parentViewController: UIViewController) {
        let menuViewController = self.makeMenuController()
        self.menuNavigationController = menuViewController
        menuViewController.view.translatesAutoresizingMaskIntoConstraints = false
        parentViewController.addChild(menuViewController)
        self.addSubview(menuViewController.view)
        NSLayoutConstraint.activate([
            menuViewController.view.topAnchor.constraint(equalTo: topSeparator?.bottomAnchor ?? topAnchor),
            menuViewController.view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            menuViewController.view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            menuViewController.view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        menuViewController.didMove(toParent: parentViewController)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        menuNavigationController?.willMove(toParent: nil)
        menuNavigationController?.view.removeFromSuperview()
        menuNavigationController?.removeFromParent()
        guard let windowRootViewController = self.window?.rootViewController?.children.last else { return }
        self.setup(parentViewController: windowRootViewController)
    }
    
    override func didShow(from textView: UITextView) {
        blockMenuActionsHandler.didShowMenuView(from: textView)
    }
    
    private func makeMenuController() -> UINavigationController {
        let coordinator = BlockMenuItemsViewControllerCoordinatorImp(actionsHandler: self.blockMenuActionsHandler,
                                                                     dismissHandler: dismissHandler)
        let controller = BlockMenuItemsViewController(coordinator: coordinator,
                                                      items: self.menuItems)
        menuItemsViewController = controller
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.isNavigationBarHidden = true
        navigationController.delegate = self
        return navigationController
    }
}

extension BlockActionsView: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        let baseBlockMenuItemsController = viewController as? BaseBlockMenuItemsViewController
        let isPresentingFirstController = viewController == navigationController.viewControllers.first
        baseBlockMenuItemsController?.setTopBarHidden(isPresentingFirstController)
    }
}

extension BlockActionsView: FilterableItemsHolder {
    
    func setFilterText(filterText: String) {
        guard let menuItemsController = self.menuItemsViewController else { return }
        if menuItemsController.navigationController?.topViewController != menuItemsController {
            menuItemsController.navigationController?.popToRootViewController(animated: false)
        }
        menuItemsController.filterString = filterText
        if menuItemsController.items.isEmpty {
            dismissHandler()
        }
    }
    
    func isDisplayingAnyItems() -> Bool {
        guard let menuController = menuItemsViewController else { return false }
        return !menuController.items.isEmpty
    }
}
