import Foundation
import Combine
import os
import BlocksModels
import ProtobufMessages


/// This class encapsulates all logic for handling events.
///
/// Setup for this class:
///
/// ```
/// let processor: EventProcessor = .init()
/// let container: BlocksModelsContainerModelProtocol = /// get container
/// processor.configured(container)
/// ```
///
/// If you want to listen events, you could use publisher:
///
/// ```
/// processor.didProcessEventsPublisher // do stuff
/// ```
///
/// If you want to handle events directly:
///
/// ```
/// processor.handle(events:)
/// ```
///
class EventProcessor {
    private var eventHandler: EventHandler
    private var eventPublisher: EventListening.NotificationEventListener<EventHandler>?
    
    // MARK: EventHandler interface
    var didProcessEventsPublisher: AnyPublisher<EventHandler.Update, Never> { self.eventHandler.didProcessEventsPublisher }

    init() {
        self.eventHandler = .init()
        self.eventPublisher = .init(handler: self.eventHandler)
    }

    private func startListening(contextId: String) {
        self.eventPublisher?.receive(contextId: contextId)
    }

    func configured(contextId: BlockId) -> Self {
        self.startListening(contextId: contextId)
        return self
    }

    func configured(_ container: TopLevelContainerModelProtocol) -> Self {
        _ = self.eventHandler.configured(container)
        if let rootId = container.rootId {
            self.startListening(contextId: rootId)
        }
        else {
            assertionFailure("We can't start listening rootId \(container.rootId) of container: \(container)")
        }
        return self
    }

    func handle(events: EventHandler.EventsContainer) {
        self.eventHandler.handle(events: events)
    }
    
    // MARK: Block Show
    func handleBlockShow(events: EventHandler.EventsContainer) -> [BlocksModelsParser.PageEvent] {
        self.eventHandler.handleBlockShow(events: events)
    }
}


// MARK: Block Show
extension EventHandler {
    func handleBlockShow(event: Anytype_Event.Message.OneOf_Value) -> BlocksModelsParser.PageEvent {
        switch event {
        case let .blockShow(value): return self.parser.parse(blocks: value.blocks, details: value.details, smartblockType: value.type)
        default: return .empty()
        }
    }

    func handleBlockShow(events: EventsContainer) -> [BlocksModelsParser.PageEvent] {
        events.events.compactMap(\.value).compactMap(self.handleBlockShow(event:))
    }
}
