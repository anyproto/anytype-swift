import UIKit
import Amplitude


final class SlashMenuView: DismissableInputAccessoryView {
    
    private enum Constants {
        static let maxMistatchFilteringCount = 3
    }
    
    var menuItems: [BlockActionMenuItem]
    private weak var menuNavigationController: UINavigationController?
    private weak var menuItemsViewController: SlashMenuItemsViewController?
    private let slashMenuActionsHandler: SlashMenuActionsHandler
    private var filterMismatchCounter = Constants.maxMistatchFilteringCount
    
    init(frame: CGRect,
         menuItems: [BlockActionMenuItem],
         slashMenuActionsHandler: SlashMenuActionsHandler) {

        self.menuItems = menuItems
        self.slashMenuActionsHandler = slashMenuActionsHandler

        super.init(frame: frame)
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
        // Analytics
        Amplitude.instance().logEvent(AmplitudeEventsName.popupSlashMenu)
        
        slashMenuActionsHandler.didShowMenuView(from: textView)
    }
    
    private func makeMenuController() -> UINavigationController {
        let coordinator = SlashMenuItemsViewControllerCoordinatorImp(actionsHandler: self.slashMenuActionsHandler,
                                                                     dismissHandler: dismissHandler)
        let controller = SlashMenuItemsViewController(coordinator: coordinator,
                                                      items: self.menuItems)
        menuItemsViewController = controller
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.isNavigationBarHidden = true
        navigationController.delegate = self
        return navigationController
    }
}

extension SlashMenuView: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        let baseBlockMenuItemsController = viewController as? BaseAccessoryMenuItemsViewController
        let isPresentingFirstController = viewController == navigationController.viewControllers.first
        baseBlockMenuItemsController?.setTopBarHidden(isPresentingFirstController)
    }
}

extension SlashMenuView: FilterableItemsView {
    
    func setFilterText(filterText: String) {
        guard let menuItemsController = self.menuItemsViewController else { return }
        if menuItemsController.navigationController?.topViewController != menuItemsController {
            menuItemsController.navigationController?.popToRootViewController(animated: false)
        }
        guard menuItemsController.filterString != filterText else { return }
        menuItemsController.filterString = filterText
        if menuItemsController.items.isEmpty {
            filterMismatchCounter -= 1
        } else {
            filterMismatchCounter = Constants.maxMistatchFilteringCount
        }
    }
    
    func shouldContinueToDisplayView() -> Bool {
        filterMismatchCounter > 0
    }
}
