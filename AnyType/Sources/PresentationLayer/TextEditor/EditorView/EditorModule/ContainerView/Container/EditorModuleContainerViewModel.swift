import Foundation
import UIKit
import Combine

final class EditorModuleContainerViewModel {
    
    // MARK: - Private variables
    
    private let router: DocumentViewBaseRouter
    private let routingProcessor: EditorContainerRoutingProcessor
    
    private var subscription: AnyCancellable?
    
    // MARK: - Initializers
    
    init(router: DocumentViewBaseRouter) {
        self.router = router
        self.routingProcessor = EditorContainerRoutingProcessor(
            eventsPublisher: router.outputEventsPublisher
        )
    }
    
    // MARK: - Internal functions
    
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

// MARK: - Actions

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
