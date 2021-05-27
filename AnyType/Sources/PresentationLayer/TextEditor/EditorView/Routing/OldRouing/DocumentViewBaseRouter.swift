import Foundation
import UIKit
import Combine
import os

/// Base Router.
/// It is base interface for all routers.
/// It adopts necessary protocols and provide API for communication from outer world.
/// If you would like to add router, it is the first place where you would like to start.
/// Do not forget to subclass following methods:
/// - `receive(action:)`
class DocumentViewBaseRouter {
    typealias UserAction = BlocksViews.UserAction
    typealias UserActionPublisher = AnyPublisher<UserAction, Never>
    typealias UserActionPublisherPublisher = AnyPublisher<UserActionPublisher, Never>
    
    // MARK: UserActions
    private var userActionsStreamSubscription: AnyCancellable?
    private var combinedUserActionsStreamSubscription: AnyCancellable?
    
    // MARK: Initialization
    init() {
        self.setupPublishers()
    }

    // MARK: Events
    private var outputEventSubject: PassthroughSubject<DocumentViewRoutingOutputEvent, Never> = .init()
    public var outputEventsPublisher: AnyPublisher<DocumentViewRoutingOutputEvent, Never> = .empty()
    private func setupPublishers() {
        self.outputEventsPublisher = self.outputEventSubject.eraseToAnyPublisher()
    }

    // MARK: Subclassing
    /// This is the method that is called from `userActionsStream`.
    /// - Parameter action: An action of BlocksViews.UserAction events that is coming from outer world.
    ///
    func receive(action: BlocksViews.UserAction) {}
    
    // MARK: Configured
    /// Well, long story to tell.
    ///
    /// If you change an array or a variable that define @Published subscription, you should resubscribe.
    ///
    /// This stream has a purpose to resubscribe to new stream.
    ///
    /// You just subscribe on a stream of streams and sink their new value.
    ///
    /// In setter of observed property you should call, for example, `PassthroughSubject` that will deliver new stream to a Stream of Stream.
    ///
    /// // In Model
    ///
    /// private var subject: PassthroughSubject<AnyPublisher<Value, Never>, Never> = .init()
    ///
    /// /// Value = [Row]
    /// @Published var buildersRows: [Row] = [] {
    ///     didSet {
    ///         self.objectWillChange.send()
    ///
    ///         let value = self.$buildersRows.map {
    ///             $0.compactMap({$0.builder as? BaseBlockViewModel})
    ///         }
    ///         .flatMap({
    ///             Publishers.MergeMany($0.map(\.userActionPublisher))
    ///         }).eraseToAnyPublisher()
    ///         self.buildersPublisherSubject.send(value)
    ///     }
    /// }
    ///
    /// - Parameter userActionsStreamStream: A stream of streams that will deliver new correct stream in its value.
    /// - Returns: A Self for convenient usage.
    func configured(userActionsStreamStream: UserActionPublisherPublisher) -> Self {
        self.combinedUserActionsStreamSubscription = userActionsStreamStream.sink(receiveValue: { [weak self] (value) in
            self?.configured(userActionsStream: value)
        })
        return self
    }

    func configured(userActionsStream: UserActionPublisher) {
        self.userActionsStreamSubscription?.cancel()
        self.userActionsStreamSubscription = nil
        self.userActionsStreamSubscription = userActionsStream.sink { [weak self] (value) in
            self?.receive(action: value)
        }
    }
}

/// Requirement: `DocumentViewRoutingOutputProtocol` is necessary for sending events to outer world.
/// We use this protocol to gather events from routing in our view controller.
extension DocumentViewBaseRouter: DocumentViewRoutingOutputProtocol {}

/// Requirement: `DocumentViewRoutingSendingOutputProtocol` is necessary for sending events to outer world.
/// However, we use it `internally`. Do not call these methods from outer world.
extension DocumentViewBaseRouter: DocumentViewRoutingSendingOutputProtocol {
    func send(event: DocumentViewRoutingOutputEvent) {
        self.outputEventSubject.send(event)
    }
}

/// It is a collection of routers which captures all events from stored routers into its own `Publishers.MergeMany` publishers.
/// It is necessary to subclass from this router if you would like to gather routers into a cluster.
/// For example, if you have text routers, maybe you want to make them via cluster.
/// So, the first place where you would start is this class.
/// Do not forget to subclass following methods:
/// - `.defaultRouters`
/// - `match(action:)`
class DocumentViewBaseCompoundRouter: DocumentViewBaseRouter {
    // MARK: Variables
    @Published private var routers: [DocumentViewBaseRouter] = []

    // MARK: Find
    /// Find router of concrete type which is subclass of our `BaseRouter`.
    /// - Parameter type: A subclass type of our `BaseRouter`.
    /// - Returns: A concrete router object which is stored in `.routers` collection.
    func router<T>(of type: T.Type) -> T? where T: DocumentViewBaseRouter {
        self.routers.filter({$0 is T}).first as? T
    }

    // MARK: Initialization
    override init() {
        super.init()
        _ = self.configured(routers: self.defaultRouters())
    }

    // MARK: Setup
    /// Setup routers by merging their `outputEventsPublisher` properties into one publisher.
    /// - Parameter routers: Routers which publishers will be merged into one publisher.
    private func setup(routers: [DocumentViewBaseRouter]) {
        self.outputEventsPublisher = Publishers.MergeMany(routers.map(\.outputEventsPublisher)).eraseToAnyPublisher()
    }

    // MARK: Subclassing

    /// Provide default routers.
    /// - Returns: Routers that will be stored in local collection.
    func defaultRouters() -> [DocumentViewBaseRouter] {
        []
    }

    /// Find correct custom router for a specific action.
    /// - Parameter action: Action for which we would like to find router.
    /// - Returns: Router that could handle specific action.
    func match(action: BlocksViews.UserAction) -> DocumentViewBaseRouter? { nil }

    // MARK: Configuration
    func configured(routers: [DocumentViewBaseRouter]) -> Self {
        self.routers = routers
        self.setup(routers: routers)
        return self
    }

    // MARK: Receive
    override func receive(action: BlocksViews.UserAction) {
        self.match(action: action).flatMap({$0.receive(action: action)})
    }
}

/// Compound router which you need to changed
class DocumentViewCompoundRouter: DocumentViewBaseCompoundRouter {

    // MARK: Subclassing
    override func match(action: BlocksViews.UserAction) -> DocumentViewBaseRouter? {
        switch action {
        case let .specific(value):
            switch value {
            case .file: return self.router(of: FileBlocksViewsRouter.self)
            case .page: return self.router(of: PageBlocksViewsRouter.self)
            }
        case .toolbars: return self.router(of: ToolbarsRouter.self)
        default: return nil
        }
    }

    override func defaultRouters() -> [DocumentViewBaseRouter] {
        [FileBlocksViewsRouter(), ToolbarsRouter(), PageBlocksViewsRouter()]
    }
}
