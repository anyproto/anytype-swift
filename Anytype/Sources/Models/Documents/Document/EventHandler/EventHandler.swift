import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import AnytypeCore

protocol EventHandlerProtocol: AnyObject {
    func handle(events: PackOfEvents)
}

final class EventHandler: EventHandlerProtocol {
    lazy var didProcessEventsPublisher = didProcessEventsSubject.eraseToAnyPublisher()
    
    private lazy var eventPublisher = NotificationEventListener(handler: self)
    private let didProcessEventsSubject = PassthroughSubject<EventHandlerUpdate, Never>()
    
    private weak var container: RootBlockContainer?
    
    private var middlewareConverter: MiddlewareEventConverter?
    private var localConverter: LocalEventConverter?
    private var mentionMarkupEventProvider: MentionMarkupEventProvider?
    
    private let pageEventConverter = PageEventConverter()

    func configured(_ container: RootBlockContainer) {
        guard let rootId = container.rootId else {
            anytypeAssertionFailure("We can't start listening rootId of container: \(container)")
            return
        }

        self.container = container
        setupMiddlewareConverter(with: container)
        localConverter = LocalEventConverter(container: container)
        eventPublisher.startListening(contextId: rootId)
        mentionMarkupEventProvider = MentionMarkupEventProvider(container: container)
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
        let markupUpdates = [mentionMarkupEventProvider?.updateMentionsEvent()].compactMap { $0 }
        let updates = middlewareUpdates + localUpdates + markupUpdates
        
        guard let container = self.container, let rootId = container.rootId else {
            anytypeAssertionFailure("Container or rootId is nil in event handler. Something went wrong.")
            return
        }
        
        updates.merged.forEach { update in
            if update.hasUpdate {
                IndentationBuilder.build(
                    container: container.blocksContainer, id: rootId
                )
            }

            didProcessEventsSubject.send(update)
        }
    }
    
    private func setupMiddlewareConverter(with container: RootBlockContainer) {
        let validator = BlockValidator(restrictionsFactory: BlockRestrictionsFactory())
        let informationCreator = BlockInformationCreator(
            validator: validator,
            container: container
        )
        middlewareConverter = MiddlewareEventConverter(
            container: container,
            informationCreator: informationCreator
        )
    }
}
