import Combine

class MultiSelectionPaneSelectAllViewModel {
    /// Initialization
    init() {
        self.setup()
    }

    /// Setup
    func setup() {
        self.userResponse = self.userResponseSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
        self.userAction = self.userActionSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
    }

    /// Publishers
    
    /// From OuterWorld
    private var subscription: AnyCancellable?
    private let userResponseSubject: PassthroughSubject<MultiSelectionPaneSelectAllUserResponse?, Never> = .init()
    private(set) var userResponse: AnyPublisher<MultiSelectionPaneSelectAllUserResponse, Never> = .empty()
            
    /// To OuterWorld
    private var userActionSubject: PassthroughSubject<MultiSelectionPaneSelectAllAction?, Never> = .init()
    var userAction: AnyPublisher<MultiSelectionPaneSelectAllAction, Never> = .empty()

    // MARK: Private Setters
    func process(action: MultiSelectionPaneSelectAllAction) {
        self.userActionSubject.send(action)
    }
    
    // MARK: Public Setters        
    func configured(userResponseStream: AnyPublisher<MultiSelectionPaneSelectAllUserResponse, Never>) -> Self {
        self.subscription = userResponseStream.sink(receiveValue: { [weak self] (value) in
            self?.userResponseSubject.send(value)
        })
        return self
    }
}
