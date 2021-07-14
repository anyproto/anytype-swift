import UIKit
import Combine
import BlocksModels

class BaseBlockViewModel: BlockViewModelProtocol {
    private enum Constants {
        static let maxIndentationLevel: Int = 4
    }
    
    let isStruct = false
    
    let block: BlockActiveRecordProtocol
    private(set) weak var blockDelegate: BlockDelegate?
    let actionHandler: EditorActionHandlerProtocol
    let router: EditorRouterProtocol
    let contextualMenuHandler: DefaultContextualMenuHandler
    

    // MARK: - Initialization

    init(
        _ block: BlockActiveRecordProtocol,
        delegate: BlockDelegate?,
        actionHandler: EditorActionHandlerProtocol,
        router: EditorRouterProtocol
    ) {
        self.block = block
        self.blockDelegate = delegate
        self.actionHandler = actionHandler
        self.router = router
        self.contextualMenuHandler = DefaultContextualMenuHandler(handler: actionHandler, router: router)
    }
    
    // MARK: - Handle events
    
    /// Update view data manually.
    /// Override in subclasses.
    func updateView() {}

    // MARK: - Contextual Menu

    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Indentation
    var indentationLevel: Int {
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
            indentationLevel
        ] as [AnyHashable]
    }

    // MARK: - ContextualMenuHandler
    func makeContextualMenu() -> ContextualMenu { .init(title: "") }

    func handle(action: ContextualMenuAction) {
        contextualMenuHandler.handle(action: action, info: block.blockModel.information)
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
    var content: BlockContent { block.blockModel.information.content }
}
