import Foundation
import Combine
import os
import BlocksModels
import ProtobufMessages

protocol EventHandlerProtocol: AnyObject {
    func handle(events: PackOfEvents)
}

class EventHandler: EventHandlerProtocol {
    lazy var didProcessEventsPublisher = didProcessEventsSubject.eraseToAnyPublisher()
    
    private lazy var eventPublisher = NotificationEventListener(handler: self)
    private let didProcessEventsSubject = PassthroughSubject<EventHandlerUpdate, Never>()
    
    private weak var container: RootBlockContainer?
    
    private var middlewareConverter: MiddlewareEventConverter?
    private var localConverter: LocalEventConverter?
    
    private let pageEventConverter = PageEventConverter()

    func configured(_ container: RootBlockContainer) {
        guard let rootId = container.rootId else {
            assertionFailure("We can't start listening rootId of container: \(container)")
            return
        }

        self.container = container
        middlewareConverter = MiddlewareEventConverter(container: container)
        localConverter = LocalEventConverter(container: container)
        eventPublisher.startListening(contextId: rootId)
    }
    
    func handleBlockShow(events: PackOfEvents) -> [PageEvent] {
        events.middlewareEvents.compactMap(\.value).compactMap { event in
            switch event {
            case let .objectShow(value):
                return pageEventConverter.convert(
                    blocks: value.blocks, details: value.details, smartblockType: value.type
                )
            default: return .empty()
            }
        }
    }
    
    func handle(events: PackOfEvents) {
        let middlewareUpdates = events.middlewareEvents.compactMap(\.value).compactMap { middlewareConverter?.convert($0) ?? nil
        }
        let localUpdates = events.localEvents.compactMap { localConverter?.convert($0) ?? nil }
        let updates = middlewareUpdates + localUpdates
        
        guard let container = self.container, let rootId = container.rootId else {
            assertionFailure("Container or rootId is nil in event handler. Something went wrong.")
            return
        }
        
        updates.merged.forEach { update in
            if update.hasUpdate {
                BlockContainerBuilder.buildTree(
                    container: container.blocksContainer, id: rootId
                )
            }

            didProcessEventsSubject.send(update)
        }
    }
}
