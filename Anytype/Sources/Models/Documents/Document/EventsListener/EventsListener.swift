import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import AnytypeCore

final class EventsListener: EventsListenerProtocol {
    
    // MARK: - Internal variables
    
    var onUpdateReceive: ((EventHandlerUpdate) -> Void)?
        
    // MARK: - Private variables
    
    private let objectId: BlockId
    private let container: RootBlockContainer
    
    private let middlewareConverter: MiddlewareEventConverter
    private let localConverter: LocalEventConverter
    private let mentionMarkupEventProvider: MentionMarkupEventProvider
    
    private var subscription: AnyCancellable?
    
    // MARK: - Initializers
    
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
    
    // MARK: - EventsListenerProtocol
    
    func startListening() {
        subscription = NotificationCenter.Publisher(
            center: .default,
            name: .middlewareEvent,
            object: nil
        )
            .compactMap { $0.object as? PackOfEvents }
            .filter { $0.objectId == self.objectId }
            .sink { [weak self] events in
                self?.handle(events: events)
            }
    }
    
    private func handle(events: PackOfEvents) {
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
