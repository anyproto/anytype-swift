import UIKit
import Combine
import BlocksModels


class BaseBlockViewModel: ObservableObject {
    private enum Constants {
        static let maxIndentationLevel: Int = 4
    }
    
    private(set) var block: BlockActiveRecordModelProtocol
    private(set) weak var baseBlockDelegate: BaseBlockDelegate?
    private(set) weak var actionHandler: NewBlockActionHandler?
    let router: EditorRouterProtocol?
    

    // MARK: - Initialization

    init(
        _ block: BlockActiveRecordModelProtocol,
        delegate: BaseBlockDelegate?,
        actionHandler: NewBlockActionHandler?,
        router: EditorRouterProtocol?
    ) {
        self.block = block
        self.baseBlockDelegate = delegate
        self.actionHandler = actionHandler
        self.router = router
    }
    
    // MARK: - Subclass / Blocks
    func update(body: (inout BlockActiveRecordModelProtocol) -> ()) {
        let isRealBlock = block.blockModel.kind == .block
        
        if isRealBlock {
            block = update(block, body: body)
        }
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
    
    // MARK: - Subclass / Information

    var information: BlockInformation { block.blockModel.information }
    
    // MARK: - Subclass / Diffable

    var diffable: AnyHashable {
        [
            information,
            indentationLevel()
        ] as [AnyHashable]
    }
    
    // MARK: - Subclass / Views

    func makeContentConfiguration() -> UIContentConfiguration { ContentConfiguration.init() }
    
    // MARK: - Subclass / Events

    func didSelectRowInTableView() {}
    
    // MARK: - Subclass / ContextualMenu

    func makeContextualMenu() -> BlocksViews.ContextualMenu { .init() }

    func handle(contextualMenuAction: BlocksViews.ContextualMenu.MenuAction.Action) {
        switch contextualMenuAction {
        case let .general(value):
            switch value {
            case .addBlockBelow:
                actionHandler?.handleAction(.addBlock(.text(.text)), model: block.blockModel)
            case .delete:
                actionHandler?.handleAction(.delete, model: block.blockModel)
            case .duplicate:
                actionHandler?.handleAction(.duplicate, model: block.blockModel)
            case .moveTo:
                break
            }
        case let .specific(value):
            switch value {
            case .turnIntoPage:
                actionHandler?.handleAction(.turnIntoBlock(.objects(.page)), model: block.blockModel)
            case .style:
                router?.showStyleMenu(block: block.blockModel, viewModel: self)
            case .color:
                break
            case .backgroundColor:
                break
            default: return
            }
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
                var identifier: UIAction.Identifier? = nil
                if let identifierStr = action.identifier {
                    identifier = UIAction.Identifier(identifierStr)
                }

                let action = UIAction(title: action.payload.title,
                                      image: action.payload.currentImage,
                                      identifier: identifier,
                                      state: .off) { action in
                    if let identifier = BlocksViews.ContextualMenu.MenuAction.Resources.IdentifierBuilder.action(for: action.identifier.rawValue) {
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
    func buildContentConfiguration() -> UIContentConfiguration { self.makeContentConfiguration() }
    
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

// MARK: - Updates (could be proposed in further releases)

extension BaseBlockViewModel {
    /// Update structure in natural `.with` way.
    /// - Parameters:
    ///   - value: a struct that you want to update
    ///   - body: block with updates.
    /// - Returns: new updated structure.
    private func update<T>(_ value: T, body: (inout T) -> ()) -> T {
        var value = value
        body(&value)
        return value
    }
}

/// Requirement: `Identifiable` is necessary for view model.
/// We use these models in plain way in `SwiftUI`.
extension BaseBlockViewModel: Identifiable {}

/// Requirement: `BlockViewBuilderProtocol` is necessary for view model.
/// We use these models in wrapped (Row contains viewModel) way in `UIKit`.
extension BaseBlockViewModel {
    var blockId: BlockId { block.blockId }
}
