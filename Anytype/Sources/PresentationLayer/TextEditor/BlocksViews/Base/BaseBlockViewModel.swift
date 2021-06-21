import UIKit
import Combine
import BlocksModels


class BaseBlockViewModel: ObservableObject {
    private enum Constants {
        static let maxIndentationLevel: Int = 4
    }
    
    private(set) var block: BlockActiveRecordModelProtocol
    private(set) weak var baseBlockDelegate: BaseBlockDelegate?

    // MARK: - Initialization

    init(_ block: BlockActiveRecordModelProtocol, delegate: BaseBlockDelegate?) {
        self.block = block
        self.baseBlockDelegate = delegate
    }
    
    // MARK: - Subclass / Blocks
    func update(body: (inout BlockActiveRecordModelProtocol) -> ()) {
        let isRealBlock = block.blockModel.kind == .block
        
        if isRealBlock {
            block = update(block, body: body)
        }
    }
    
    // MARK: - Events
    
    private var userActionSubject = PassthroughSubject<BlockUserAction, Never>()
    public lazy var userActionPublisher = userActionSubject.eraseToAnyPublisher()
    
    // MARK: Toolbar Action Publisher

    /// This Pair ( Publisher and Subject ) can manipulate with `ActionsPayload.Toolbar.Action`.
    /// For example, if you would like to show AddBlock toolbar, you will do these steps:
    ///
    /// 1. Create an action that will show desired Toolbar ( AddBlock in our case. )
    /// 2. Set Output to `toolbarActionSubject` for this AddBlock Toolbar.
    /// 3. Send `showEvent` to `userActionSubject` with desired configured action ( show(AddBlockToolbar(action(output)))
    /// 4. Listen `toolbarActionPublisher` for incoming events from user.
    ///
    /// If user press something, then AddBlockToolbar will send user action to `PassthroughSubject` ( or `toolbarActionSubject` in our case ).
    ///
    public private(set) var toolbarActionSubject: PassthroughSubject<BlockToolbarAction, Never> = .init()
    public lazy var toolbarActionPublisher: AnyPublisher<BlockToolbarAction, Never> = toolbarActionSubject.eraseToAnyPublisher()

    // MARK: Actions Payload Publisher

    private(set) var actionsPayloadSubject: PassthroughSubject<ActionsPayload, Never> = .init()
    
    private var actionsPayloadSubjectSubscription: AnyCancellable?
    
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
                toolbarActionSubject.send(.addBlock(.text(.text)))
            case .delete:
                toolbarActionSubject.send(.editBlock(.delete))
            case .duplicate:
                toolbarActionSubject.send(.editBlock(.duplicate))
            case .moveTo:
                break
            }
        case let .specific(value):
            switch value {
            case .turnIntoPage:
                toolbarActionSubject.send(.turnIntoBlock(.objects(.page)))
            case .style:
                send(
                    actionsPayload: .showStyleMenu(
                        blockModel: block.blockModel,
                        blockViewModel: self
                    )
                )
            case .color:
                break
            case .backgroundColor:
                break
            default: return
            }
        }
    }
    
    func send(userAction: BlockUserAction) {
        userActionSubject.send(userAction)
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

// MARK: - Configurations

extension BaseBlockViewModel {
    
    func configured(userActionSubject: PassthroughSubject<BlockUserAction, Never>) {
        self.userActionSubject = userActionSubject
        self.userActionPublisher = self.userActionSubject.eraseToAnyPublisher()
    }
    
    func configured(actionsPayloadSubject: PassthroughSubject<ActionsPayload, Never>) {
        self.actionsPayloadSubject = actionsPayloadSubject
        
        let toolbarPublisher = self.toolbarActionPublisher.map({ [weak self] value -> ActionsPayload? in
            guard let block = self?.block else { return nil }
            return ActionsPayload.toolbar(.init(model: block, action: value))
        }).safelyUnwrapOptionals()
        
        self.actionsPayloadSubjectSubscription = toolbarPublisher.sink(receiveValue: { [weak self] (value) in
            self?.actionsPayloadSubject.send(value)
        })
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

extension BaseBlockViewModel {
    // Send actions payload
    func send(actionsPayload: ActionsPayload) {
        actionsPayloadSubject.send(actionsPayload)
    }
}
