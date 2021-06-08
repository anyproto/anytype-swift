import UIKit
import Combine
import BlocksModels


class BaseBlockViewModel: ObservableObject {
    private enum Constants {
        static let maxIndentationLevel: Int = 4
    }
    
    private(set) var block: BlockActiveRecordModelProtocol

    // MARK: - Initialization

    init(_ block: BlockActiveRecordModelProtocol) {
        self.block = block
        
        setupPublishers()
    }
    
    // MARK: - Subclass / Blocks
    func update(body: (inout BlockActiveRecordModelProtocol) -> ()) {
        let isRealBlock = block.blockModel.kind == .block
        
        if isRealBlock {
            block = update(block, body: body)
        }
    }
    
    // MARK: - Events
    // MARK: User Action Publisher

    /// This publisher sends actions to, in most cases, routing.
    /// If you would like to show controllers or action panes, you should listen events from this publisher.
    ///
    private var userActionSubject: PassthroughSubject<BlocksViews.UserAction, Never> = .init()
    public var userActionPublisher: AnyPublisher<BlocksViews.UserAction, Never> = .empty()
    
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
    public private(set) var toolbarActionSubject: PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never> = .init()
    public var toolbarActionPublisher: AnyPublisher<BlocksViews.Toolbar.UnderlyingAction, Never> = .empty()
    
    // MARK: Marks Pane Publisher

    /// This Pair ( Publisher and Subject ) can manipuate with `MarksPane.Main.Action`.
    /// If you would like to show `MarksPane`, you will need to configure specific action.
    ///
    /// These steps are necessary.
    ///
    /// 1. Create and action that will show desired MarksPane ( our MarksPane ).
    /// 2. Set Output to `marksPaneActionSubject` for this MarksPane.
    /// 3. Send `showEvent` to `userActionSubject` with desired configured action ( show(MarksPaneToolbar(action(output))) )
    /// 4. Also, if you would like configuration, you could set input as init-parameters. Look at apropriate `Input`.
    /// 5. Listen `marksPaneActionPublisher` for incoming events from user.
    ///
    /// If user press something, then MarksPane will send user action to `PassthroughSubject` ( or `marksPaneActionSubject` in our case )
    ///
    public private(set) var marksPaneActionSubject: PassthroughSubject<MarksPane.Main.Action, Never> = .init()
    public var marksPaneActionPublisher: AnyPublisher<MarksPane.Main.Action, Never> = .empty()

    // MARK: Actions Payload Publisher

    /// This solo Publisher `actionsPayloadPublisher` merges all actions into meta `ActionsPayload` action.
    /// If you need to process whole user input for specific BlocksViewModel, you need to listen this publisher.
    ///
    private(set) var actionsPayloadSubject: PassthroughSubject<ActionsPayload, Never> = .init()
    // TODO: what purpose is it here for?
    public var actionsPayloadPublisher: AnyPublisher<ActionsPayload, Never> = .empty()
    
    /// We use this subject with `.send()` internally.
    /// Also, we merged it with toolbar action publisher.
    /// For that reason, we should add subscription and subscribe this subject on toolbar publisher.
    /// self.subscription = `toolbarPublisher.subscribe(self.actionsPayloadSubject)`.
    /// We need it to receive updates from toolbar actions
    /// And from our actions.
    ///
    private var actionsPayloadSubjectSubscription: AnyCancellable?
    
    /// DidChange Size Subject.
    /// Whenever item changes size ( or thinking so ), we have to notify our document view model about it.
    /// This can be done via "PassthroughSubject as Delegate" technique.
    var sizeDidChangeSubject: PassthroughSubject<Void, Never> = .init()
    
    // MARK: - Handle events

    /// This methods can be overriden in subclasses
    /// - Parameter toolbarAction: Toolbar action type
    ///
    /// Default implementation do nothing
    func handle(toolbarAction: BlocksViews.Toolbar.UnderlyingAction) {}
    
    func handle(marksPaneAction: MarksPane.Main.Action) {
        // Do nothing? We need external custom processors?
        switch marksPaneAction {
        case .style: return
        case .textColor: return
        case .backgroundColor: return // set background color of view and send sets background color.
        }
    }

    /// Update view data manually.
    /// Override in subclasses.
    func updateView() {}
    
    // MARK: - Setup / Publishers

    private func setupPublishers() {
        self.userActionPublisher = self.userActionSubject.eraseToAnyPublisher()
        self.toolbarActionPublisher = self.toolbarActionSubject.eraseToAnyPublisher()
        self.marksPaneActionPublisher = self.marksPaneActionSubject.eraseToAnyPublisher()

        // TODO: what purpose is it here for?
        let actionsPayloadPublisher = self.actionsPayloadSubject
        let toolbarActionPublisher = self.toolbarActionPublisher.map({ [weak self] value in
            self.flatMap({ActionsPayload.toolbar(.init(model: $0.block, action: value))})
        }).safelyUnwrapOptionals()
        let marksPaneActionPublisher = self.marksPaneActionSubject.map({ [weak self] value in
            self.flatMap({ActionsPayload.marksPane(.init(model: $0.block, action: value))})
        }).safelyUnwrapOptionals()

        // TODO: what purpose is it here for?
        self.actionsPayloadPublisher = Publishers.Merge3(actionsPayloadPublisher.eraseToAnyPublisher(), toolbarActionPublisher.eraseToAnyPublisher(), marksPaneActionPublisher.eraseToAnyPublisher()).eraseToAnyPublisher()
    }
    
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
        [information.id,
         BlockContentTypeIdentifier.identifier(self.information.content),
         indentationLevel()] as [AnyHashable]
    }
    
    // MARK: - Subclass / Views

    func makeContentConfiguration() -> UIContentConfiguration { ContentConfiguration.init() }
    
    // MARK: - Subclass / Events

    func handle(event: BlocksViews.UserEvent) {}
    
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
            case .turnInto:
                send(userAction: .toolbars(.turnIntoBlock(.init(output: self.toolbarActionSubject))))
            case .turnIntoPage:
                toolbarActionSubject.send(.turnIntoBlock(.objects(.page)))
            case .style: self.send(userAction: .toolbars(.marksPane(.mainPane(.init(output: self.marksPaneActionSubject, input: .init(userResponse: nil, section: .style))))))
            case .color: self.send(userAction: .toolbars(.marksPane(.mainPane(.init(output: self.marksPaneActionSubject, input: .init(userResponse: nil, section: .textColor))))))
            case .backgroundColor:
                let color = MiddlewareModelsModule.Parsers.Text.Color.Converter.asModel(block.blockModel.information.backgroundColor, background: true) ?? .defaultColor
                self.send(userAction: .toolbars(.marksPane(.mainPane(.init(output: self.marksPaneActionSubject, input: .init(userResponse: .init(backgroundColor: color), section: .backgroundColor, shouldPluginOutputIntoInput: true))))))
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

// MARK: - Configurations

extension BaseBlockViewModel {
    /// TODO: Remove later. Maybe we don't need this publisher.
    func configured(sizeDidChangeSubject: PassthroughSubject<Void, Never>) {
        self.sizeDidChangeSubject = sizeDidChangeSubject
    }

    func configured(userActionSubject: PassthroughSubject<BlocksViews.UserAction, Never>) {
        self.userActionSubject = userActionSubject
        self.userActionPublisher = self.userActionSubject.eraseToAnyPublisher()
    }
    
    func configured(actionsPayloadSubject: PassthroughSubject<ActionsPayload, Never>) {
        self.actionsPayloadSubject = actionsPayloadSubject
        
        let toolbarPublisher = self.toolbarActionPublisher.map({ [weak self] value -> ActionsPayload? in
            guard let block = self?.block else { return nil }
            return ActionsPayload.toolbar(.init(model: block, action: value))
        }).safelyUnwrapOptionals()
        
        let marksPanePublisher = self.marksPaneActionPublisher.map({ [weak self] value in
            self.flatMap({ActionsPayload.marksPane(.init(model: $0.block, action: value))})
        }).safelyUnwrapOptionals()

        let allInOnePublisher = Publishers.Merge(toolbarPublisher, marksPanePublisher)
        self.actionsPayloadSubjectSubscription = allInOnePublisher.sink(receiveValue: { [weak self] (value) in
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

/// Requirement: `Blocks ViewsUserActionsEmittingProtocol` is necessary to subclasses of view model.
/// We could send events to `userActionPublisher`.
extension BaseBlockViewModel: BlocksViewsUserActionsEmittingProtocol {
    
    func send(userAction: BlocksViews.UserAction) {
        self.userActionSubject.send(userAction)
    }
    
}

/// Requirement: `BlocksViewsUserActionsSubscribingProtocol` is necessary for routing and outer world.
/// We could subscribe on `userActionPublisher` and react on changes.
extension BaseBlockViewModel: BlocksViewsUserActionsSubscribingProtocol {}

/// Requirement: `BlocksViewsUserActionsReceivingProtocol` is necessary for communication from outer space.
/// We could send events to blocks views to perform actions and get reactions.
extension BaseBlockViewModel: BlocksViewsUserActionsReceivingProtocol {
    func receive(event: BlocksViews.UserEvent) {
        self.handle(event: event)
    }
}
