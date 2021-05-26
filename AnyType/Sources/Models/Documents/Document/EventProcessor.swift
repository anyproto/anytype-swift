import Foundation
import Combine
import os
import BlocksModels
import ProtobufMessages


/// This class encapsulates all logic for handling events.
class EventProcessor {
    private let eventHandler = EventHandler()
    private lazy var eventPublisher = NotificationEventListener(handler: eventHandler)
    
    // MARK: EventHandler interface
    var didProcessEventsPublisher: AnyPublisher<EventHandlerUpdate, Never> { self.eventHandler.didProcessEventsPublisher }

    func configured(_ container: ContainerModel) {
        eventHandler.configured(container)
        
        guard let rootId = container.rootId else {
            assertionFailure("We can't start listening rootId of container: \(container)")
            return
        }
        
        eventPublisher.startListening(contextId: rootId)
    }

    func handle(events: PackOfEvents) {
        eventHandler.handle(events: events)
    }
    
    func handleBlockShow(events: PackOfEvents) -> [BlocksModelsParser.PageEvent] {
        eventHandler.handleBlockShow(events: events)
    }
}
