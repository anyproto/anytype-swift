import UIKit
import Services
import AnytypeCore

final class SlashMenuView: DismissableInputAccessoryView {
    
    private var menuItems = [SlashMenuItem]()
    private var filterStringMismatchLength = 0
    private var cachedFilterText = ""
    
    private let viewModel: SlashMenuViewModel
    private let cellDataBuilder = SlashMenuCellDataBuilder()
    private let itemsBuilder = SlashMenuItemsBuilder()
    private var searchMenuItemsTask: Task<(), Never>?
    
    init(frame: CGRect, viewModel: SlashMenuViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        
        setup()
    }
    
    private func setup() {
        addSubview(navigationController.view) {
            if FeatureFlags.ipadIncreaseWidth {
                $0.pinToSuperview(excluding: [.top])
            } else {
                $0.pinToSuperviewPreservingReadability(excluding: [.top])
            }
            $0.top.equal(to: topSeparator?.bottomAnchor ?? topAnchor)
        }
    }
    
    func update(spaceId: String, info: BlockInformation, relations: [Relation]) {
        searchMenuItemsTask?.cancel()

        viewModel.info = info
        let restrictions = BlockRestrictionsBuilder.build(contentType: info.content.type)
    
        Task { @MainActor [weak self] in
            self?.menuItems = (try? await self?.itemsBuilder.slashMenuItems(spaceId: spaceId, resrictions: restrictions, relations: relations)) ?? []
            self?.restoreDefaultState()
        }
    }
    
    func restoreDefaultState() {
        filterStringMismatchLength = 0
        cachedFilterText = ""
        popTooRoot()
        
        controller.cellData = cellDataBuilder.build(menuItems: menuItems)
    }
    
    override func didShow(from textView: UITextView) {
        viewModel.didShowMenuView(from: textView)
    }
    
    private func popTooRoot() {
        if controller.navigationController?.topViewController != controller {
            controller.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    // MARK: - Controllers
    private lazy var navigationController: UINavigationController = {
        let navigationController = BaseNavigationController(rootViewController: controller)
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [
            NSAttributedString.Key.font: AnytypeFont.uxTitle2Medium.uiKitFont
        ]
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.shadowColor = .Background.primary
        navBarAppearance.backgroundColor = .Background.primary
        navBarAppearance.setBackIndicatorImage(UIImage(asset: .X18.slashMenuArrow), transitionMaskImage: UIImage(asset: .X18.slashMenuArrow))
        navigationController.modifyBarAppearance(navBarAppearance)
        navigationController.navigationBar.tintColor = .Button.active
        
        return navigationController
    }()
    
    private lazy var controller = SlashMenuAssembly
        .menuController(viewModel: viewModel, dismissHandler: dismissHandler)
}

extension SlashMenuView: FilterableItemsView {
    
    func setFilterText(filterText: String) {
        guard cachedFilterText != filterText else { return }
        
        popTooRoot()
        
        controller.cellData = cellDataBuilder.build(filter: filterText, menuItems: menuItems)
        
        if !controller.cellData.isEmpty {
            filterStringMismatchLength = 0
        } else {
            filterStringMismatchLength += filterText.count - cachedFilterText.count
        }
        
        cachedFilterText = filterText
    }
}

extension SlashMenuView: DismissStatusProvider {
    var shouldDismiss: Bool {
        filterStringMismatchLength > 3
    }
}
