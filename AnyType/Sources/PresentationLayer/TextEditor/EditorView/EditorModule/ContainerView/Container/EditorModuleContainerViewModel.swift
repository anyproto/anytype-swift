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
        case show(UIViewController)
        case child(UIViewController)
        case showDocument(EditorModuleContentModule)
        case childDocument(EditorModuleContentModule)
        case pop
    }
}

// MARK: ViewModel
class EditorModuleContainerViewModel {
    private var router: DocumentViewRoutingOutputProtocol
    private let routingProcessor: EditorContainerRoutingProcessor
    
    private var subscription: AnyCancellable?
    
    init(router: DocumentViewRoutingOutputProtocol) {
        self.router = router
        self.routingProcessor = EditorContainerRoutingProcessor(eventsPublisher: router.outputEventsPublisher)
    }
    
    /// And publish on actions that associated controller will handle.
    func actionPublisher() -> AnyPublisher<Action, Never> {
        self.routingProcessor.userAction.map { value -> Action in
            switch value {
            case let .childDocument(value):
                return .childDocument(value)
            case let .showDocument(value):
                return .showDocument(value)
            default: return value
            }
        }.eraseToAnyPublisher()
    }
}

// MARK: Configurations
extension EditorModuleContainerViewModel {
    func configured(userActionsStream: DocumentViewBaseRouter.UserActionPublisher) -> Self {
        let router = (self.router as? DocumentViewBaseRouter)
        _ = router?.configured(userActionsStream: userActionsStream)
        return self
    }
}
