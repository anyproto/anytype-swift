import Foundation
import UIKit
import Combine
import os

/// Do not forget to subclass following methods:
/// - `receive(action:)`
class DocumentViewBaseRouter {
    
    private var userActionsStreamSubscription: AnyCancellable?
    
    // MARK: Events
    public lazy var outputEventsPublisher: AnyPublisher<DocumentViewRoutingOutputEvent, Never> = outputEventSubject.eraseToAnyPublisher()
    private let outputEventSubject = PassthroughSubject<DocumentViewRoutingOutputEvent, Never>()
    
    // MARK: Subclassing
    /// This is the method that is called from `userActionsStream`.
    /// - Parameter action: An action of BlocksViews.UserAction events that is coming from outer world.
    ///
    func receive(action: BlocksViews.UserAction) {}
    
    func configure(userActionsStream: AnyPublisher<BlocksViews.UserAction, Never>) {
        userActionsStreamSubscription = nil
        userActionsStreamSubscription = userActionsStream.sink { [weak self] value in
            self?.receive(action: value)
        }
    }
    
}

/// Requirement: `DocumentViewRoutingSendingOutputProtocol` is necessary for sending events to outer world.
/// However, we use it `internally`. Do not call these methods from outer world.
extension DocumentViewBaseRouter: DocumentViewRoutingSendingOutputProtocol {
    
    func send(event: DocumentViewRoutingOutputEvent) {
        self.outputEventSubject.send(event)
    }
    
}

/// Requirement: `DocumentViewRoutingOutputProtocol` is necessary for sending events to outer world.
/// We use this protocol to gather events from routing in our view controller.
extension DocumentViewBaseRouter: DocumentViewRoutingOutputProtocol {}
