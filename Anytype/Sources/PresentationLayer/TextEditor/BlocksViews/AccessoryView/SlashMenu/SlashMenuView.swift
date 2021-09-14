import UIKit
import Amplitude


final class SlashMenuView: DismissableInputAccessoryView {
    
    private enum Constants {
        static let maxMistatchFilteringCount = 3
    }
    
    var menuItems = [SlashMenuItem]()
    private weak var menuNavigationController: UINavigationController?
    private lazy var controller = SlashMenuAssembly(actionsHandler: actionsHandler)
        .menuController(menuItems: menuItems, dismissHandler: dismissHandler)
    private let actionsHandler: SlashMenuActionsHandler
    private let cellDataBuilder: SlashMenuCellDataBuilder
    private var filterStringMismatchLength = 0
    private var cachedFilterText = ""
    
    init(
        frame: CGRect,
        actionsHandler: SlashMenuActionsHandler
    ) {
        self.actionsHandler = actionsHandler
        self.cellDataBuilder = SlashMenuCellDataBuilder(menuItems: menuItems)

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
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.isNavigationBarHidden = true
        navigationController.delegate = self
        
        menuNavigationController = navigationController
        navigationController.view.translatesAutoresizingMaskIntoConstraints = false
        parentViewController.addChild(navigationController)
        addSubview(navigationController.view) {
            $0.pinToSuperview(excluding: [.top])
            $0.top.equal(to: topSeparator?.bottomAnchor ?? topAnchor)
        }
        navigationController.didMove(toParent: parentViewController)
    }
    
    override func didShow(from textView: UITextView) {
        Amplitude.instance().logEvent(AmplitudeEventsName.popupSlashMenu)
        
        actionsHandler.didShowMenuView(from: textView)
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
        if controller.navigationController?.topViewController != controller {
            controller.navigationController?.popToRootViewController(animated: false)
        }
        guard cachedFilterText != filterText else { return }
        controller.cellData = cellDataBuilder.build(filter: filterText)
        
        if !controller.cellData.isEmpty {
            filterStringMismatchLength = 0
        } else {
            filterStringMismatchLength += filterText.count - cachedFilterText.count
        }
        cachedFilterText = filterText
    }
    
    func shouldContinueToDisplayView() -> Bool {
        filterStringMismatchLength <= Constants.maxMistatchFilteringCount
    }
}
