import Foundation
import Combine
import os
import BlocksModels
import ProtobufMessages

class EventHandler: EventHandlerProtocol {
    private var didProcessEventsSubject: PassthroughSubject<EventHandlerUpdate, Never> = .init()
    let didProcessEventsPublisher: AnyPublisher<EventHandlerUpdate, Never>
    
    private weak var container: ContainerModel?
    
    private var updater: BlockUpdater?
    private var innerConverter: InnerEventConverter?
    private var ourConverter: OurEventConverter?
    
    let parser = BlocksModelsParser()
    
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
            TopLevelBuilderImpl.blockBuilder.buildTree(container: container.blocksContainer, rootId: container.rootId)
        }

        // Notify about updates if needed.
        self.didProcessEventsSubject.send(update)
    }
    
    func handle(events: EventListening.PackOfEvents) {
        let innerUpdates = events.events.compactMap(\.value).compactMap { innerConverter?.convert($0) ?? nil }
        let ourUpdates = events.ourEvents.compactMap { ourConverter?.convert($0) ?? nil }
        self.finalize(innerUpdates + ourUpdates)
    }

    // MARK: Configurations
    func configured(_ container: ContainerModel) {
        self.updater = BlockUpdater(container)
        self.container = container
        self.innerConverter = InnerEventConverter(parser: self.parser, updater: self.updater, container: self.container)
        self.ourConverter = OurEventConverter(container: self.container)
    }
}
