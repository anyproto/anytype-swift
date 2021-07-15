import Foundation
import Combine
import os
import BlocksModels
import ProtobufMessages

protocol EventHandlerProtocol: AnyObject {
    func handle(events: PackOfEvents)
}

class EventHandler: EventHandlerProtocol {
    private lazy var eventPublisher = NotificationEventListener(handler: self)
    private let didProcessEventsSubject = PassthroughSubject<EventHandlerUpdate, Never>()
    lazy var didProcessEventsPublisher = didProcessEventsSubject.eraseToAnyPublisher()
    
    private weak var container: RootBlockContainer?
    
    private var innerConverter: MiddlewareEventConverter?
    private var ourConverter: LocalEventConverter?
    
    private let pageEventConverter = PageEventConverter()
                                    
    private func finalize(_ updates: [EventHandlerUpdate]) {
        let update = updates.reduce(EventHandlerUpdate.update(EventHandlerUpdatePayload())) { result, update in
            .merged(lhs: result, rhs: update)
        }
        
        guard let container = self.container else {
            assertionFailure("Container is nil in event handler. Something went wrong.")
            return
        }

        if update.hasUpdate {
            BlockContainerBuilder.buildTree(container: container.blocksContainer, rootId: container.rootId)
        }

        // Notify about updates if needed.
        self.didProcessEventsSubject.send(update)
    }
    
    func handle(events: PackOfEvents) {
        let innerUpdates = events.events.compactMap(\.value).compactMap { innerConverter?.convert($0) ?? nil }
        let ourUpdates = events.localEvents.compactMap { ourConverter?.convert($0) ?? nil }
        finalize(innerUpdates + ourUpdates)
    }

    // MARK: Configurations
    func configured(_ container: RootBlockContainer) {
        guard let rootId = container.rootId else {
            assertionFailure("We can't start listening rootId of container: \(container)")
            return
        }

        self.container = container
        innerConverter = MiddlewareEventConverter(container: container)
        ourConverter = LocalEventConverter(container: container)
        eventPublisher.startListening(contextId: rootId)
    }
    
    func handleBlockShow(events: PackOfEvents) -> [PageEvent] {
        events.events.compactMap(\.value).compactMap(
            self.handleBlockShow(event:)
        )
    }
    
    private func handleBlockShow(event: Anytype_Event.Message.OneOf_Value) -> PageEvent {
        switch event {
        case let .objectShow(value):
            return pageEventConverter.convert(blocks: value.blocks, details: value.details, smartblockType: value.type)
        default: return .empty()
        }
    }
}
