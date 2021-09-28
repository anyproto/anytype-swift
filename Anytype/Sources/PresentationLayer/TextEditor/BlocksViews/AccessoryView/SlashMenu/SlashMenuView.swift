import UIKit
import Amplitude
import BlocksModels

final class SlashMenuView: DismissableInputAccessoryView {
    
    private var menuItems = [SlashMenuItem]()
    private var filterStringMismatchLength = 0
    private var cachedFilterText = ""
    
    private lazy var navigationController = UINavigationController(rootViewController: controller)
    private lazy var controller = SlashMenuAssembly
        .menuController(viewModel: viewModel, dismissHandler: dismissHandler)
    
    private let viewModel: SlashMenuViewModel
    private let cellDataBuilder = SlashMenuCellDataBuilder()
    
    init(frame: CGRect, viewModel: SlashMenuViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        
        setup()
    }
    
    private func setup() {
        navigationController.setNavigationBarHidden(true, animated: false)
        addSubview(navigationController.view) {
            $0.pinToSuperview(excluding: [.top])
            $0.top.equal(to: topSeparator?.bottomAnchor ?? topAnchor)
        }
    }
    
    func update(block: BlockModelProtocol) {
        viewModel.block = block
        menuItems = SlashMenuItemsBuilder(blockType: block.information.content.type).slashMenuItems
        
        restoreDefaultState()
    }
    
    func restoreDefaultState() {
        filterStringMismatchLength = 0
        cachedFilterText = ""
        
        controller.cellData = cellDataBuilder.build(menuItems: menuItems)
    }
    
    override func didShow(from textView: UITextView) {
        Amplitude.instance().logEvent(AmplitudeEventsName.popupSlashMenu)
        
        viewModel.didShowMenuView(from: textView)
    }
    
}

extension SlashMenuView: FilterableItemsView {
    
    func setFilterText(filterText: String) {
        if controller.navigationController?.topViewController != controller {
            controller.navigationController?.popToRootViewController(animated: false)
        }
        guard cachedFilterText != filterText else { return }
        
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
