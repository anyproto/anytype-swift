import Combine

class MultiSelectionPaneDoneViewModel {
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
    private var userResponseSubject: PassthroughSubject<MultiSelectionPaneDoneUserResponse?, Never> = .init()
    private(set) var userResponse: AnyPublisher<MultiSelectionPaneDoneUserResponse, Never> = .empty()
            
    /// To OuterWorld
    private var userActionSubject: PassthroughSubject<MultiSelectionPaneDoneAction?, Never> = .init()
    var userAction: AnyPublisher<MultiSelectionPaneDoneAction, Never> = .empty()

    // MARK: Private Setters
    func process(action: MultiSelectionPaneDoneAction) {
        self.userActionSubject.send(action)
    }
}
