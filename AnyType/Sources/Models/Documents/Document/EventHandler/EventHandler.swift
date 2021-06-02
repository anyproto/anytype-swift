import Foundation
import Combine
import os
import BlocksModels
import ProtobufMessages

protocol EventHandlerProtocol: AnyObject {
    func handle(events: PackOfEvents)
}

class EventHandler: EventHandlerProtocol {
    private var didProcessEventsSubject: PassthroughSubject<EventHandlerUpdate, Never> = .init()
    let didProcessEventsPublisher: AnyPublisher<EventHandlerUpdate, Never>
    
    private weak var container: ContainerModelProtocol?
    
    private var innerConverter: InnerEventConverter?
    private var ourConverter: OurEventConverter?
    
    let pageEventConverter = PageEventConverter()
    
    init() {
        self.didProcessEventsPublisher = self.didProcessEventsSubject.eraseToAnyPublisher()
    }
                                    
    private func finalize(_ updates: [EventHandlerUpdate]) {
        let update = updates.reduce(EventHandlerUpdate.update(EventHandlerUpdatePayload())) { result, update in
            .merged(lhs: result, rhs: update)
        }
        
        guard let container = self.container else {
            assertionFailure("Container is nil in event handler. Something went wrong.")
            return
        }

        if update.hasUpdate {
            TopLevelBuilder.blockBuilder.buildTree(container: container.blocksContainer, rootId: container.rootId)
        }

        // Notify about updates if needed.
        self.didProcessEventsSubject.send(update)
    }
    
    func handle(events: PackOfEvents) {
        let innerUpdates = events.events.compactMap(\.value).compactMap { innerConverter?.convert($0) ?? nil }
        let ourUpdates = events.ourEvents.compactMap { ourConverter?.convert($0) ?? nil }
        finalize(innerUpdates + ourUpdates)
    }

    // MARK: Configurations
    func configured(_ container: ContainerModelProtocol) {
        self.container = container
        self.innerConverter = InnerEventConverter(updater: BlockUpdater(container), container: self.container)
        self.ourConverter = OurEventConverter(container: container)
    }
    
    func handleBlockShow(events: PackOfEvents) -> [PageEvent] {
        events.events.compactMap(\.value).compactMap(self.handleBlockShow(event:))
    }
    
    private func handleBlockShow(event: Anytype_Event.Message.OneOf_Value) -> PageEvent {
        switch event {
        case let .objectShow(value): return pageEventConverter.convert(blocks: value.blocks, details: value.details, smartblockType: value.type)
        default: return .empty()
        }
    }
}
