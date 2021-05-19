import UIKit
import Combine
import BlocksModels


// MARK: - Options

extension BaseBlockViewModel {
    /// Actually, `feature flags`.
    struct Options {
        var shouldAddContextualMenu: Bool = true
    }
}

// MARK: - OuterWorld Publishers and Subjects

extension BaseBlockViewModel {
    /// This AactionsPayload describes all actions that user can do with BlocksViewsModels.
    /// For example, user can press long-tap and active toolbar.
    /// Or user could interact with text view.
    /// Possibly, that we need to separate text view actions.
    enum ActionsPayload {
        struct Toolbar {
            typealias Action = BlocksViews.Toolbar.UnderlyingAction
            let model: BlockModel
            let action: Action
        }

        struct MarksPaneHolder {
            typealias Action = MarksPane.Main.Action
            let model: BlockModel
            let action: Action
        }

        /// For backward compatibility.
        struct TextBlocksViewsUserInteraction {
            typealias Action = TextBlockUserInteraction
            let model: BlockModel
            let action: Action
        }

        /// For seamless usage of UserAction as "Payload"
        struct UserActionHolder {
            typealias Action = BlocksViews.UserAction
            let model: BlockModel
            let action: Action
        }

        /// Text blocks draft.
        /// It should hold also toggle from `TextBlocksViewsUserInteraction`.
        /// Name it properly.
        struct TextBlockViewModelPayload {
            enum Action {
                case text(NSAttributedString)
                case alignment(NSTextAlignment)
                case checked(Bool)
            }

            var model: BlockModel
            var action: Action
        }

        case toolbar(Toolbar)
        case marksPane(MarksPaneHolder)
        case textView(TextBlocksViewsUserInteraction)
        case userAction(UserActionHolder)
        /// show code language view
        case showCodeLanguageView(languages: [String], completion: (String) -> Void)
        /// show style menu
        case showStyleMenu(BlockModelProtocol)
        /// tell that block become first responder
        case becomeFirstResponder(BlockModelProtocol)
    }

    // Send actions payload
    func send(actionsPayload: ActionsPayload) {
        self.actionsPayloadSubject.send(actionsPayload)
    }

    /// Ask update layout
    ///
    /// View could ask to update layout due to some inner layout events (view could changed its size, position or similar)
    func needsUpdateLayout() {
        self.sizeDidChangeSubject.send()
    }
}

// MARK: - BaseBlockViewModel class

/// Base block view model
class BaseBlockViewModel: ObservableObject {
    
    private enum Constants {
        static let maxIndentationLevel: Int = 4
    }
    
    typealias BlockModel = BlockActiveRecordModelProtocol
    typealias Information = BlockInformation.InformationModel
    
    // MARK: Variables
    /// our Block
    /// Maybe we should made it Observable?.. Let think a bit about it.
    private var block: BlockModel
    
    /// Options that handle a behavior of view model.
    private var options: Options = .init()
    
    // MARK: - Initialization

    init(_ block: BlockModel) {
        self.block = block
        self.diffable = makeDiffable()
        self.configure()
    }
    
    /// Configure
    /// Call this method before you want to use view model.
    func configure() {
        self.setupPublishers()
        self.setupSubscriptions()
    }
            
    // MARK: - Subclass / Blocks
    
    // MARK: Block model processing
    func getBlock() -> BlockModel { self.block }

    func isRealBlock() -> Bool { self.getBlock().blockModel.kind == .block }

    func update(block: (inout BlockModel) -> ()) {
        if isRealBlock() {
            self.block = update(getBlock(), body: block)
//                self.blockUpdatesSubject.send(self.block)
        }
    }
    
    /// Check whether is possible to drop other block to this to create parent-child relation
    func canHaveChildren() -> Bool {
        switch block.blockModel.information.content {
        case let .text(text):
            switch text.contentType {
            case .text, .checkbox, .toggle, .bulleted, .numbered:
                return true
            default:
                return false
            }
        case let .link(link):
            switch link.style {
            case .page:
                return true
            case .dataview, .archive:
                return false
            }
        default:
            return false
        }
    }

    /// Call when block become first responder
    func becomeFirstResponder() {
        send(actionsPayload: .becomeFirstResponder(block.blockModel))
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
    public private(set) var toolbarActionSubject: PassthroughSubject<ActionsPayload.Toolbar.Action, Never> = .init()
    public var toolbarActionPublisher: AnyPublisher<ActionsPayload.Toolbar.Action, Never> = .empty()
    
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
    private var sizeDidChangeSubject: PassthroughSubject<Void, Never> = .init()
    
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
    
    // MARK: - Setup / Subscriptions

    private func setupSubscriptions() {
        self.contextualMenuInteractor.provider = self
        self.contextualMenuInteractor.actionSubject.sink { [weak self] (value) in
            self?.handle(contextualMenuAction: value)
        }.store(in: &self.subscriptions)
    }
    
    // MARK: - Contextual Menu

    private var subscriptions: Set<AnyCancellable> = []
    private var contextualMenuInteractor: ContextualMenuInteractor = .init()
    weak var contextualMenuDelegate: UIContextMenuInteractionDelegate? { self.contextualMenuInteractor }
                    
    // MARK: - Indentation
    func indentationLevel() -> Int {
        min(self.getBlock().indentationLevel, Constants.maxIndentationLevel)
    }
    
    // MARK: - Subclass / Information

    var information: BlockInformation.InformationModel { self.getBlock().blockModel.information }
    
    // MARK: - Subclass / Diffable

    private(set) var diffable: AnyHashable = .init("")
    
    /// Here we use the following technique.
    /// As soon as we should recreate our ViewModels very often, we should keep their identity somewhere.
    /// So, it is kind of "fingerprint" of "initial" block.
    /// As soon as we use `block` as `shared` entity, we should struggle with its nature in this way.
    /// Again.
    /// Treat this property `_diffableStorage` as `initial` fingerprint of block.
    ///
    func makeDiffable() -> AnyHashable {
        [
            "Id": self.information.id,
            "Content": BlockContentTypeIdentifier.identifier(self.information.content),
            "Indentation": self.indentationLevel()
        ] as [AnyHashable: AnyHashable]
    }
    
    func updateDiffable() {
        diffable = makeDiffable()
    }
    
    // MARK: - Subclass / Views

    func makeUIView() -> UIView { .init() }
    func makeContentConfiguration() -> UIContentConfiguration { ContentConfiguration.init() }
    
    // MARK: - Subclass / Events

    func handle(event: BlocksViews.UserEvent) {}
    
    // MARK: - Subclass / ContextualMenu

    func makeContextualMenu() -> BlocksViews.ContextualMenu { .init() }

    func handle(contextualMenuAction: BlocksViews.ContextualMenu.MenuAction.Action) {
        switch contextualMenuAction {
        case let .general(value):
            switch value {
            case .addBlockBelow: self.send(userAction: .toolbars(.addBlock(.init(output: self.toolbarActionSubject, input: nil))))
            case .delete: self.toolbarActionSubject.send(.editBlock(.delete))
            case .duplicate: self.toolbarActionSubject.send(.editBlock(.duplicate))
            case .moveTo: break
            }
        case let .specific(value):
            switch value {
            case .turnInto: self.send(userAction: .toolbars(.turnIntoBlock(.init(output: self.toolbarActionSubject))))
            case .style: self.send(userAction: .toolbars(.marksPane(.mainPane(.init(output: self.marksPaneActionSubject, input: .init(userResponse: nil, section: .style))))))
            case .color: self.send(userAction: .toolbars(.marksPane(.mainPane(.init(output: self.marksPaneActionSubject, input: .init(userResponse: nil, section: .textColor))))))
            case .backgroundColor:
                let color = MiddlewareModelsModule.Parsers.Text.Color.Converter.asModel(self.getBlock().blockModel.information.backgroundColor, background: true) ?? .defaultColor
                self.send(userAction: .toolbars(.marksPane(.mainPane(.init(output: self.marksPaneActionSubject, input: .init(userResponse: .init(backgroundColor: color), section: .backgroundColor, shouldPluginOutputIntoInput: true))))))
            default: return
            }
        }
    }
}

// MARK: - Hashable

extension BaseBlockViewModel: Hashable {
    static func == (lhs: BaseBlockViewModel, rhs: BaseBlockViewModel) -> Bool {
        lhs.blockId == rhs.blockId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.blockId)
    }
}

// MARK: - Configurations

extension BaseBlockViewModel {
    /// TODO: Remove later. Maybe we don't need this publisher.
    func configured(sizeDidChangeSubject: PassthroughSubject<Void, Never>) -> Self {
        self.sizeDidChangeSubject = sizeDidChangeSubject
        return self
    }

    func configured(userActionSubject: PassthroughSubject<BlocksViews.UserAction, Never>) -> Self {
        self.userActionSubject = userActionSubject
        self.userActionPublisher = self.userActionSubject.eraseToAnyPublisher()
        return self
    }
    
    func configured(actionsPayloadSubject: PassthroughSubject<ActionsPayload, Never>) -> Self {
        self.actionsPayloadSubject = actionsPayloadSubject
        /// Discussion:
        /// Do we have here retain cycle?
        /// I guess that we don't have.
        /// Because (self.flatMap) here stands for Optional<Self> and this is value type.
        /// Next, we call function from Optional<Self>: `.flatMap`
//        let toolbarPublisher = self.toolbarActionPublisher.map({ [weak self] value in
//            self.flatMap({ActionsPayload.toolbar(.init(model: $0.block, action: value))})
//        }).safelyUnwrapOptionals()
        
        let toolbarPublisher = self.toolbarActionPublisher.map({ [weak self] value -> ActionsPayload? in
            guard let block = self?.block else { return nil }
            return ActionsPayload.toolbar(.init(model: block, action: value))
        }).safelyUnwrapOptionals()
        
        let marksPanePublisher = self.marksPaneActionPublisher.map({ [weak self] value in
            self.flatMap({ActionsPayload.marksPane(.init(model: $0.block, action: value))})
        }).safelyUnwrapOptionals()


        /// Discussion:
        /// Do we have here retain cycle?
        /// `toolbarPublisher` is stored in our property, yes.
        /// However, we use some transforms on our publisher.
//        self.actionsPayloadSubjectSubscription = toolbarPublisher.subscribe(self.actionsPayloadSubject)
        let allInOnePublisher = Publishers.Merge(toolbarPublisher, marksPanePublisher)
        self.actionsPayloadSubjectSubscription = allInOnePublisher.sink(receiveValue: { [weak self] (value) in
            self?.actionsPayloadSubject.send(value)
        })
        return self
    }
}

// MARK: - Options

extension BaseBlockViewModel {
    func configured(_ options: Options) -> Self {
        self.options = options
        return self
    }
}

// MARK: - Contextual Menu

extension BaseBlockViewModel {
    func buildContextualMenu() -> BlocksViews.ContextualMenu {
        self.makeContextualMenu()
    }
}

// MARK: - UIContextMenuInteractionDelegate

private extension BaseBlockViewModel {
    class ContextualMenuInteractor: NSObject, UIContextMenuInteractionDelegate {
        // MARK: Conversion BlocksViews.ContextualMenu.MenuAction <-> UIAction.Identifier
        enum IdentifierConverter {
            static func action(for menuAction: BlocksViews.ContextualMenu.MenuAction) -> UIAction.Identifier? {
                menuAction.identifier.flatMap({UIAction.Identifier.init($0)})
            }
            static func menuAction(for identifier: UIAction.Identifier?) -> BlocksViews.ContextualMenu.MenuAction.Action? {
                identifier.flatMap({BlocksViews.ContextualMenu.MenuAction.Resources.IdentifierBuilder.action(for: $0.rawValue)})
            }
        }
        
        // MARK: Provider
        /// Actually, Self
        weak var provider: BaseBlockViewModel?
        
        // MARK: Subject ( Subsribe on it ).
        var actionSubject: PassthroughSubject<BlocksViews.ContextualMenu.MenuAction.Action, Never> = .init()
        
        // MARK: Conversion BlocksViews.ContextualMenu and BlocksViews.ContextualMenu.MenuAction
        static func menu(from: BlocksViews.ContextualMenu?) -> UIMenu? {
            from.flatMap{ .init(title: $0.title, image: nil, identifier: nil, options: .init(), children: []) }
        }
        
        static func action(from action: BlocksViews.ContextualMenu.MenuAction, handler: @escaping (UIAction) -> ()) -> UIAction {
            .init(title: action.payload.title, image: action.payload.currentImage, identifier: IdentifierConverter.action(for: action), discoverabilityTitle: nil, attributes: [], state: .off, handler: handler)
        }
        
        // MARK: Delegate methods

        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            .init(identifier: "" as NSCopying, previewProvider: nil) { [weak self] (value) -> UIMenu? in
                let menu = self?.provider?.buildContextualMenu()
                return menu.flatMap {
                    .init(title: $0.title, image: nil, identifier: nil, options: .init(), children: $0.children.map { [weak self] child in
                        ContextualMenuInteractor.action(from: child) { [weak self] (action) in
                            IdentifierConverter.menuAction(for: action.identifier).flatMap({self?.actionSubject.send($0)})
                        }
                    })
                }
            }
        }
    }
}

// MARK: - UIKit / Context menu embedding

extension BaseBlockViewModel {
    class OurContextMenuInteraction: UIContextMenuInteraction {
        /// Uncomment later if needed.
        /// Also, you should update delegate by `update(delegate:)` when view apply(configuration:) method has been called.
        typealias Delegate = UIContextMenuInteractionDelegate

        class ProxyChain: NSObject, Delegate {
            private var delegate: Delegate?
            func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
                self.delegate?.contextMenuInteraction(interaction, configurationForMenuAtLocation: location)
            }
            func update(_ delegate: Delegate?) {
                self.delegate = delegate
            }
        }

        /// Proxy
        private var proxyChain: ProxyChain = .init()
        private var ourDelegate: Delegate { self.proxyChain }

        /// Initialization
        override init(delegate: Delegate) {
            self.proxyChain.update(delegate)
            super.init(delegate: self.proxyChain)
        }

        func update(delegate: Delegate) {
            self.proxyChain.update(delegate)
        }

        /// UIContextMenuInteractionDelegate
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            self.ourDelegate.contextMenuInteraction(interaction, configurationForMenuAtLocation: location)
        }
    }

    /// We need this method, because it goes insane if you add hundreds of interactions.
    /// True story.
    ///
    /// HINT: We could add setter/getter `self.delegate` for `OurContextMenuInteraction` and update only delegate instead of add/removing.
    func addContextMenuIfNeeded(_ view: UIView) {
        self.updateContextMenu(view)
    }

    private func addContextMenu(_ view: UIView) {
        if let delegate = self.contextualMenuDelegate, self.options.shouldAddContextualMenu {
            let interaction = OurContextMenuInteraction.init(delegate: delegate)
            view.addInteraction(interaction)
        }
    }

    private func updateContextMenu(_ view: UIView) {
        if let interaction = view.interactions.first(where: {$0 is OurContextMenuInteraction}) as? OurContextMenuInteraction {
            if let delegate = self.contextualMenuDelegate, self.options.shouldAddContextualMenu {
                interaction.update(delegate: delegate)
            }
        }
        else {
            self.addContextMenu(view)
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
extension BaseBlockViewModel: BlockViewBuilderProtocol {
    var blockId: BlockID { self.getBlock().blockModel.information.id }
    
//    var id: IndexID { .init() } // Unused, actually, so, conform as you want.

    func buildUIView() -> UIView {
        let view = makeUIView()
        self.addContextMenuIfNeeded(view)
        return view
    }
}

/// Requirement: `Block sViewsUserActionsEmittingProtocol` is necessary to subclasses of view model.
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
