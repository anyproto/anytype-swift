import Foundation
import UIKit
import Combine


// MARK: Actions
extension EditorModuleContainerViewModel {
    /// An outgoing action that will come from this view model.
    ///
    /// Generally, corresponing `ViewController` of this `viewModel` will subscribe on these actions.
    ///
    enum Action {
        typealias Document = EditorModuleContainerViewBuilder.ChildComponent
        case show(UIViewController)
        case child(UIViewController)
        case showDocument(Document)
        case childDocument(Document)
        case pop
    }
}

// MARK: RouterProcessor
extension EditorModuleContainerViewModel {
    private class RoutingProcessor {
        /// Aliases
        typealias IncomingEvent = DocumentViewRouting.OutputEvent
        typealias UserAction = Action
        
        /// Variables
        private var subscription: AnyCancellable?
        private var userActionSubject: PassthroughSubject<UserAction, Never> = .init()
        fileprivate var userAction: AnyPublisher<UserAction, Never> = .empty()
        
        /// TODO: Maybe extract to some entity
        func build(id: String) -> EditorModuleContainerViewBuilder.ChildComponent {
            let component = EditorModuleContainerViewBuilder.childComponent(id: id)
            /// Next, we should configure router and, well, we should configure navigation item, of course...
            /// But we don't know anything about navigation item here...
            /// We could ask ViewModel to configure and then send this event to view controller.
            return component
        }
        
        /// Processing
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
        
        /// Initialization
        init() {
            self.userAction = self.userActionSubject.eraseToAnyPublisher()
        }
        
        /// Configurations
        func configured(_ eventsPublisher: AnyPublisher<IncomingEvent, Never>?) {
            self.subscription = eventsPublisher?.sink(receiveValue: { [weak self] (value) in
                self?.process(value)
            })
        }
    }
}

// MARK: ViewModel
class EditorModuleContainerViewModel {
    /// Keep router and routing processor in one place.
    private var router: DocumentViewRoutingOutputProtocol?
    private var routingProcessor: RoutingProcessor = .init()
    
    private var subscription: AnyCancellable?
    /// And publish on actions that associated controller will handle.
    func actionPublisher() -> AnyPublisher<Action, Never> {
        self.routingProcessor.userAction.map { value -> Action in
            switch value {
            case let .childDocument(value):
                _ = value.childComponent.viewModel
//                    _ = self?.configured(userActionsStream: viewModel.soloUserActionPublisher)
                return .childDocument(value)
            case let .showDocument(value):
                _ = value.childComponent.viewModel
//                    _ = self?.configured(userActionsStream: viewModel.soloUserActionPublisher)
                return .showDocument(value)
            default: return value
            }
        }.eraseToAnyPublisher()
    }
}

// MARK: Configurations
extension EditorModuleContainerViewModel {
    func configured(router: DocumentViewRoutingOutputProtocol?) -> Self {
        self.router = router
        self.routingProcessor.configured(self.router?.outputEventsPublisher)
        return self
    }
    
    func configured(userActionsStream: DocumentViewRouting.BaseRouter.UserActionPublisher) -> Self {
        let router = (self.router as? DocumentViewRouting.BaseRouter)
        _ = router?.configured(userActionsStream: userActionsStream)
        return self
    }
    
    func configured(userActionsStreamStream: DocumentViewRouting.BaseRouter.UserActionPublisherPublisher) -> Self {
        let router = (self.router as? DocumentViewRouting.BaseRouter)
        _ = router?.configured(userActionsStreamStream: userActionsStreamStream)
        return self
    }
    
    func forcedConfigured(userActionsStream: DocumentViewRouting.BaseRouter.UserActionPublisher) {
        let router: DocumentViewRouting.CompoundRouter = .init()
        _ = self.configured(router: router)
        _ = router.configured(userActionsStream: userActionsStream)
    }
}

