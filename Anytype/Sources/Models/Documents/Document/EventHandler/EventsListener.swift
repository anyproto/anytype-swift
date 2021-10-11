import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import AnytypeCore

protocol EventHandlerProtocol: AnyObject {
    var onUpdateReceive: ((EventHandlerUpdate) -> Void)? { get set }
    func handle(events: PackOfEvents)
}

final class EventsListener: EventHandlerProtocol {
    
    var onUpdateReceive: ((EventHandlerUpdate) -> Void)?
        
    private let objectId: BlockId
    private let container: RootBlockContainer
    
    private let middlewareConverter: MiddlewareEventConverter
    private let localConverter: LocalEventConverter
    private let mentionMarkupEventProvider: MentionMarkupEventProvider
    
    private var subscription: AnyCancellable?
    
    init(objectId: BlockId, container: RootBlockContainer) {
        self.objectId = objectId
        self.container = container
        
        let validator = BlockValidator(
            restrictionsFactory: BlockRestrictionsFactory()
        )
        let informationCreator = BlockInformationCreator(
            validator: validator,
            container: container
        )
        self.middlewareConverter = MiddlewareEventConverter(
            container: container,
            informationCreator: informationCreator
        )
        self.localConverter = LocalEventConverter(container: container)
        self.mentionMarkupEventProvider = MentionMarkupEventProvider(
            container: container,
            objectId: objectId
        )
    }
    
    func startListening() {
        subscription = NotificationCenter.Publisher(
            center: .default,
            name: .middlewareEvent,
            object: nil
        )
            .compactMap { $0.object as? Anytype_Event }
            .filter {$0.contextID == self.objectId}
            .sink { [weak self] event in
                self?.handle(
                    events: PackOfEvents(middlewareEvents: event.messages)
                )
            }
    }
    
    func handleBlockShow(events: PackOfEvents) -> [PageData] {
        events.middlewareEvents
            .compactMap(\.value)
            .compactMap { event in
                guard case .objectShow(let value) = event else { return nil }
                
                return PageEventConverter.convert(
                    blocks: value.blocks,
                    details: value.details,
                    smartblockType: value.type
                )
            }
    }
    
    func handle(events: PackOfEvents) {
        let middlewareUpdates = events.middlewareEvents.compactMap(\.value).compactMap { middlewareConverter.convert($0) ?? nil
        }
        let localUpdates = events.localEvents.compactMap { localConverter.convert($0) ?? nil }
        let markupUpdates = [mentionMarkupEventProvider.updateMentionsEvent()].compactMap { $0 }
        let updates = middlewareUpdates + localUpdates + markupUpdates
        
        updates.merged.forEach { update in
            if update.hasUpdate {
                IndentationBuilder.build(
                    container: container.blocksContainer,
                    id: objectId
                )
            }
            
            onUpdateReceive?(update)
        }
    }
    
}
