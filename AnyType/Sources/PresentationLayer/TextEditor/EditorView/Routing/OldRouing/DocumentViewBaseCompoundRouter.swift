import Combine

/// It is a collection of routers which captures all events from stored routers into its own `Publishers.MergeMany` publishers.
/// It is necessary to subclass from this router if you would like to gather routers into a cluster.
/// For example, if you have text routers, maybe you want to make them via cluster.
/// So, the first place where you would start is this class.
/// Do not forget to subclass following methods:
/// - `.defaultRouters`
/// - `match(action:)`
class DocumentViewBaseCompoundRouter: DocumentViewBaseRouter {
    
    // MARK: - Variables
    
    @Published private var routers: [DocumentViewBaseRouter] = []

    // MARK: - Initialization
    
    override init() {
        super.init()
        
        routers = self.defaultRouters()
        
        self.outputEventsPublisher = Publishers.MergeMany(
            routers.map(\.outputEventsPublisher)
        ).eraseToAnyPublisher()
    }
    
    // MARK: - Override
    
    override func receive(action: BlocksViews.UserAction) {
        self.match(action: action).flatMap({$0.receive(action: action)})
    }

    /// Provide default routers.
    /// - Returns: Routers that will be stored in local collection.
    func defaultRouters() -> [DocumentViewBaseRouter] {
        []
    }
    
    /// Find correct custom router for a specific action.
    /// - Parameter action: Action for which we would like to find router.
    /// - Returns: Router that could handle specific action.
    func match(action: BlocksViews.UserAction) -> DocumentViewBaseRouter? {
        nil
    }
    
    // MARK: Find
    /// Find router of concrete type which is subclass of our `BaseRouter`.
    /// - Parameter type: A subclass type of our `BaseRouter`.
    /// - Returns: A concrete router object which is stored in `.routers` collection.
    func router<T>(of type: T.Type) -> T? where T: DocumentViewBaseRouter {
        routers.filter { $0 is T }.first as? T
    }
    
}
