import Combine

class MultiSelectionPaneToolbarViewModel {
    typealias UserResponse = MultiSelectionPaneToolbarUserResponse
    typealias Action = MultiSelectionPaneToolbarAction
    
    // MARK: Initialization
    init() {
        self.setup()
    }

    // MARK: Setup
    func setup() {
        self.userResponse = self.userResponseSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
        self.userAction = self.userActionSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
    }

    // MARK: Publishers
    
    /// From OuterWorld
    private var subscription: AnyCancellable?
    private var userResponseSubject: PassthroughSubject<UserResponse?, Never> = .init()
    var userResponse: AnyPublisher<UserResponse, Never> = .empty()
            
    /// To OuterWorld
    private var userActionSubject: PassthroughSubject<Action?, Never> = .init()
    var userAction: AnyPublisher<Action, Never> = .empty()

    // MARK: Private Setters
    func process(action: Action) {
        self.userActionSubject.send(action)
    }
    
    // MARK: Public Setters
    /// Use this method from outside to update value.
    ///
    func handle(countOfObjects: Int, turnIntoStyles: [BlocksViews.Toolbar.BlocksTypes]) {
        self.userResponseSubject.send(countOfObjects <= 0 ? .isEmpty : .nonEmpty(count: .init(countOfObjects), turnIntoStyles: turnIntoStyles))
    }
    
    func subscribe(on userResponse: AnyPublisher<MultiSelectionMainPane.UserResponse, Never>) {
        self.subscription = userResponse.sink(receiveValue: { [weak self] (value) in
            self?.handle(countOfObjects: value.selectedItemsCount,
                         turnIntoStyles: value.turnIntoStyles)
        })
    }
    
    func configured(userResponseStream: AnyPublisher<MultiSelectionMainPane.UserResponse, Never>) -> Self {
        self.subscribe(on: userResponseStream)
        return self
    }
}
