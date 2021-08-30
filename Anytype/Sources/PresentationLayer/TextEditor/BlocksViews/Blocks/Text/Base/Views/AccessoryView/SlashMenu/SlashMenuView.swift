import UIKit
import Amplitude


final class SlashMenuView: DismissableInputAccessoryView {
    
    private enum Constants {
        static let maxMistatchFilteringCount = 3
    }
    
    var menuItems: [BlockActionMenuItem]
    private weak var menuNavigationController: UINavigationController?
    private weak var menuItemsViewController: SlashMenuViewController?
    private let slashMenuActionsHandler: SlashMenuActionsHandler
    private var filterStringMismatchLength = 0
    
    init(
        frame: CGRect,
        menuItems: [BlockActionMenuItem],
        slashMenuActionsHandler: SlashMenuActionsHandler
    ) {
        self.menuItems = menuItems
        self.slashMenuActionsHandler = slashMenuActionsHandler

        super.init(frame: frame)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        menuNavigationController?.willMove(toParent: nil)
        menuNavigationController?.view.removeFromSuperview()
        menuNavigationController?.removeFromParent()
        
        filterStringMismatchLength = 0
        
        guard let windowRootViewController = window?.rootViewController?.children.last else { return }
        setup(parentViewController: windowRootViewController)
    }
    
    private func setup(parentViewController: UIViewController) {
        let menuViewController = makeMenuController()
        menuNavigationController = menuViewController
        menuViewController.view.translatesAutoresizingMaskIntoConstraints = false
        parentViewController.addChild(menuViewController)
        addSubview(menuViewController.view) {
            $0.pinToSuperview(excluding: [.top])
            $0.top.equal(to: topSeparator?.bottomAnchor ?? topAnchor)
        }
        menuViewController.didMove(toParent: parentViewController)
    }
    
    override func didShow(from textView: UITextView) {
        Amplitude.instance().logEvent(AmplitudeEventsName.popupSlashMenu)
        
        slashMenuActionsHandler.didShowMenuView(from: textView)
    }
    
    // MARK: - Views
    
    private func makeMenuController() -> UINavigationController {
        let coordinator = SlashMenuViewControllerCoordinatorImp(
            actionsHandler: slashMenuActionsHandler,
            dismissHandler: dismissHandler
        )
        let controller = SlashMenuViewController(
            coordinator: coordinator,
            items: menuItems
        )
        menuItemsViewController = controller
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.isNavigationBarHidden = true
        navigationController.delegate = self
        return navigationController
    }
}

extension SlashMenuView: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        let baseBlockMenuItemsController = viewController as? SlashMenuViewController
        let isPresentingFirstController = viewController == navigationController.viewControllers.first
        baseBlockMenuItemsController?.setTopBarHidden(isPresentingFirstController)
    }
}

extension SlashMenuView: FilterableItemsView {
    
    func setFilterText(filterText: String) {
        guard let menuItemsController = menuItemsViewController else { return }
        if menuItemsController.navigationController?.topViewController != menuItemsController {
            menuItemsController.navigationController?.popToRootViewController(animated: false)
        }
        guard menuItemsController.filterString != filterText else { return }
        
        let oldFilterText = menuItemsController.filterString
        menuItemsController.filterString = filterText
        
        if !menuItemsController.items.isEmpty {
            filterStringMismatchLength = 0
            return
        }
        filterStringMismatchLength += filterText.count - oldFilterText.count
    }
    
    func shouldContinueToDisplayView() -> Bool {
        filterStringMismatchLength <= Constants.maxMistatchFilteringCount
    }
}
