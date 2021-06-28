import UIKit
import Combine
import BlocksModels

protocol ContextualMenuHandler {
    func makeContextualMenu() -> ContextualMenu
    func handle(contextualMenuAction: ContextualMenuAction)
}

protocol DiffableProvier {
    var diffable: AnyHashable { get }
}

class BaseBlockViewModel: DiffableProvier, ContextualMenuHandler {
    private enum Constants {
        static let maxIndentationLevel: Int = 4
    }
    
    let block: BlockActiveRecordProtocol
    private(set) weak var baseBlockDelegate: BaseBlockDelegate?
    private(set) weak var actionHandler: NewBlockActionHandler?
    let router: EditorRouterProtocol?
    

    // MARK: - Initialization

    init(
        _ block: BlockActiveRecordProtocol,
        delegate: BaseBlockDelegate?,
        actionHandler: NewBlockActionHandler?,
        router: EditorRouterProtocol?
    ) {
        self.block = block
        self.baseBlockDelegate = delegate
        self.actionHandler = actionHandler
        self.router = router
    }
    
    // MARK: - Handle events
    
    /// Update view data manually.
    /// Override in subclasses.
    func updateView() {}

    // MARK: - Contextual Menu

    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Indentation
    func indentationLevel() -> Int {
        min(block.indentationLevel, Constants.maxIndentationLevel)
    }
    
    // MARK: - Subclass / Views

    func makeContentConfiguration() -> UIContentConfiguration { ContentConfiguration.init() }
    
    // MARK: - Subclass / Events

    func didSelectRowInTableView() {}
    
    // MARK: - DiffableProvier

    var diffable: AnyHashable {
        [
            information,
            indentationLevel()
        ] as [AnyHashable]
    }

    // MARK: - ContextualMenuHandler
    func makeContextualMenu() -> ContextualMenu { .init(title: "") }

    func handle(contextualMenuAction: ContextualMenuAction) {
        switch contextualMenuAction {
        case .addBlockBelow:
            actionHandler?.handleAction(.addBlock(.text(.text)), model: block.blockModel)
        case .delete:
            actionHandler?.handleAction(.delete, model: block.blockModel)
        case .duplicate:
            actionHandler?.handleAction(.duplicate, model: block.blockModel)
        case .turnIntoPage:
            actionHandler?.handleAction(.turnIntoBlock(.objects(.page)), model: block.blockModel)
        case .style:
            router?.showStyleMenu(block: block.blockModel, viewModel: self)
        case .moveTo, .color, .backgroundColor:
            break
        case .download,.replace, .addCaption, .rename:
            break
        }
    }
}

// MARK: - Hashable

// TIP: Doesn't called in collection view.
extension BaseBlockViewModel: Hashable {
    static func == (lhs: BaseBlockViewModel, rhs: BaseBlockViewModel) -> Bool {
        lhs.diffable == rhs.diffable
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(diffable)
    }
}

// MARK: - Contextual Menu

extension BaseBlockViewModel {

    func contextMenuInteraction() -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] (value) -> UIMenu? in
            guard let menu = self?.makeContextualMenu() else { return nil }

            let uiActions = menu.children.map { action -> UIAction in
                let identifier = UIAction.Identifier(action.identifier)

                let action = UIAction(title: action.title, image: action.image, identifier: identifier, state: .off) { action in
                    if let identifier = ContextualMenuIdentifierBuilder.action(for: action.identifier.rawValue) {
                        self?.handle(contextualMenuAction: identifier)
                    }
                }
                return action
            }
            return UIMenu(title: menu.title, children: uiActions)
        }
    }
}

// MARK: - UIKit / ContentConfiguration

extension BaseBlockViewModel {
    
    private struct ContentConfiguration: UIContentConfiguration {
        func makeContentView() -> UIView & UIContentView { ContentView(configuration: self) }
        
        func updated(for state: UIConfigurationState) -> ContentConfiguration { self }
    }
    
    private class ContentView: UIView, UIContentView {
        var configuration: UIContentConfiguration

        init(configuration: UIContentConfiguration) {
            self.configuration = configuration
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension BaseBlockViewModel {
    var blockId: BlockId { block.blockId }
    var information: BlockInformation { block.blockModel.information }
}
