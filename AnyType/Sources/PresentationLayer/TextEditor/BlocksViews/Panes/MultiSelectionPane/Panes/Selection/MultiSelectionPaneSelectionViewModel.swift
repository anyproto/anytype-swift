import Combine

class MultiSelectionPaneSelectionViewModel {
    typealias UserResponse = MultiSelectionPaneSelectionUserResponse
    typealias SelectAll = MultiSelectionPane.Panes.Selection.SelectAll
    typealias Action = MultiSelectionPaneSelectionAction
    
    // MARK: Initialization
    init() {
        self.setup()
    }

    // MARK: Setup
    func setup() {
        
        // From OuterWorld
        self.userResponse = self.userResponseSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
        
        _ = self._selectAllViewModel.configured(userResponseStream: self.userResponse.map { value -> SelectAll.UserResponse in
            switch value {
            case let .selection(value): return value
            }
        }.eraseToAnyPublisher())
        
        // To OuterWorld
        self.userAction = Publishers.Merge(
            self._selectAllViewModel.userAction.map(Action.selectAll),
            self._doneViewModel.userAction.map(Action.done)
        ).eraseToAnyPublisher()
    }
    
    // MARK: ViewModels
    private var _selectAllViewModel: MultiSelectionPane.Panes.Selection.SelectAll.ViewModel = .init()
    private var _doneViewModel: MultiSelectionPane.Panes.Selection.Done.ViewModel = .init()
    
    // MARK: Publishers
    private var subscription: AnyCancellable?
    
    /// From OuterWorld
    private var userResponseSubject: PassthroughSubject<UserResponse?, Never> = .init()
    var userResponse: AnyPublisher<UserResponse, Never> = .empty()
            
    /// To OuterWorld
    var userAction: AnyPublisher<Action, Never> = .empty()

    // MARK: Public Setters
    /// Use this method from outside to update value.
    ///
    func handle(countOfObjects: Int) {
        self.userResponseSubject.send(.selection(countOfObjects <= 0 ? .isEmpty : .nonEmpty(UInt(countOfObjects))))
    }
    
    func configured(userResponseStream: AnyPublisher<Int, Never>) -> Self {
        self.subscription = userResponseStream.sink(receiveValue: { [weak self] (value) in
            self?.handle(countOfObjects: value)
        })
        return self
    }
    
    func selectAllViewModel() -> MultiSelectionPane.Panes.Selection.SelectAll.ViewModel {
        self._selectAllViewModel
    }
    
    func doneViewModel() -> MultiSelectionPane.Panes.Selection.Done.ViewModel {
        self._doneViewModel
    }
}
