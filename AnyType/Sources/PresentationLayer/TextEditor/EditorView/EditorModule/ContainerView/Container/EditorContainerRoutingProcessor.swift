import Combine

class EditorContainerRoutingProcessor {
    typealias IncomingEvent = DocumentViewRouting.OutputEvent
    typealias UserAction = EditorModuleContainerViewModel.Action
    
    private var subscription: AnyCancellable?
    private let userActionSubject = PassthroughSubject<UserAction, Never>()
    let userAction: AnyPublisher<UserAction, Never>
    
    func build(id: String) -> EditorModuleContentModule {
        let component = EditorModuleContainerViewBuilder.childComponent(id: id)
        /// Next, we should configure router and, well, we should configure navigation item, of course...
        /// But we don't know anything about navigation item here...
        /// We could ask ViewModel to configure and then send this event to view controller.
        return component
    }
    
    func process(_ value: IncomingEvent) {
        switch value {
        case let .general(value):
            switch value {
            case let .show(value): self.userActionSubject.send(.show(value))
            case let .child(value): self.userActionSubject.send(.child(value))
            }
        case let .document(value):
            switch value {
            case let .show(id):
                let viewController = self.build(id: id)
                self.userActionSubject.send(.showDocument(viewController))
            case let .child(id):
                let viewController = self.build(id: id)
                self.userActionSubject.send(.childDocument(viewController))
            }
        }
    }
    
    init() {
        userAction = userActionSubject.eraseToAnyPublisher()
    }
    
    func configured(_ eventsPublisher: AnyPublisher<IncomingEvent, Never>?) {
        self.subscription = eventsPublisher?.sink(receiveValue: { [weak self] (value) in
            self?.process(value)
        })
    }
}
