import UIKit

final class BlockActionsView: DismissableInputAccessoryView {
    
    private enum Constants {
        static let separatorHeight: CGFloat = 0.5
    }
    
    private weak var menuViewController: UIViewController?
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
        let topSeparator = self.addTopSeparator()
        let menuViewController = self.makeMenuController()
        self.menuViewController = menuViewController
        menuViewController.view.translatesAutoresizingMaskIntoConstraints = false
        parentViewController.addChild(menuViewController)
        self.addSubview(menuViewController.view)
        NSLayoutConstraint.activate([
            menuViewController.view.topAnchor.constraint(equalTo: topSeparator.bottomAnchor),
            menuViewController.view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            menuViewController.view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            menuViewController.view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        menuViewController.didMove(toParent: parentViewController)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        menuViewController?.willMove(toParent: nil)
        subviews.forEach { $0.removeFromSuperview() }
        menuViewController?.removeFromParent()
        guard let windowRootViewController = self.window?.rootViewController?.children.last else { return }
        self.setup(parentViewController: windowRootViewController)
    }
    
    private func addTopSeparator() -> UIView {
        let topSeparator = UIView()
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        topSeparator.backgroundColor = .systemGray4
        self.addSubview(topSeparator)
        NSLayoutConstraint.activate([
            topSeparator.topAnchor.constraint(equalTo: self.topAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: Constants.separatorHeight),
            topSeparator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        return topSeparator
    }
    
    private func makeMenuController() -> UIViewController {
        let coordinator = BlockMenuItemsViewControllerCoordinatorImp(actionsHandler: self.blockMenuActionsHandler,
                                                                     dismissHandler: dismissHandler)
        let controller = BlockMenuItemsViewController(coordinator: coordinator,
                                                      items: self.menuItems)
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
