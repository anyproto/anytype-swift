import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import AnytypeCore

final class EventsListener: EventsListenerProtocol {
    
    // MARK: - Internal variables
    
    var onUpdateReceive: ((EventsListenerUpdate) -> Void)?
        
    // MARK: - Private variables
    
    private let objectId: BlockId
     
    private let blocksContainer: BlockContainerModelProtocol
    private let detailsStorage: ObjectDetailsStorageProtocol
    
    private let middlewareConverter: MiddlewareEventConverter
    private let localConverter: LocalEventConverter
    private let mentionMarkupEventProvider: MentionMarkupEventProvider
    
    private var subscription: AnyCancellable?
    
    // MARK: - Initializers
    
    init(
        objectId: BlockId,
        blocksContainer: BlockContainerModelProtocol,
        detailsStorage: ObjectDetailsStorageProtocol
    ) {
        self.objectId = objectId
        self.blocksContainer = blocksContainer
        self.detailsStorage = detailsStorage
        
        let validator = BlockValidator(
            restrictionsFactory: BlockRestrictionsFactory()
        )
        let informationCreator = BlockInformationCreator(
            validator: validator,
            blocksContainer: blocksContainer
        )
        self.middlewareConverter = MiddlewareEventConverter(
            blocksContainer: blocksContainer,
            detailsStorage: detailsStorage,
            informationCreator: informationCreator
        )
        self.localConverter = LocalEventConverter(
            blocksContainer: blocksContainer,
            detailsStorage: detailsStorage
        )
        self.mentionMarkupEventProvider = MentionMarkupEventProvider(
            objectId: objectId,
            blocksContainer: blocksContainer,
            detailsStorage: detailsStorage
        )
    }
    
    // MARK: - EventsListenerProtocol
    
    func startListening() {
        subscription = NotificationCenter.Publisher(
            center: .default,
            name: .middlewareEvent,
            object: nil
        )
            .compactMap { $0.object as? EventsBunch }
            .filter { $0.objectId == self.objectId }
            .sink { [weak self] events in
                self?.handle(events: events)
            }
    }
    
    private func handle(events: EventsBunch) {
        let middlewareUpdates = events.middlewareEvents.compactMap(\.value).compactMap { middlewareConverter.convert($0) }
        let localUpdates = events.localEvents.compactMap { localConverter.convert($0) }
        let markupUpdates = [mentionMarkupEventProvider.updateMentionsEvent()].compactMap { $0 }
        let updates = middlewareUpdates + localUpdates + markupUpdates
        
        updates.merged.forEach { update in
            if update.hasUpdate {
                IndentationBuilder.build(
                    container: blocksContainer,
                    id: objectId
                )
            }
            
            onUpdateReceive?(update)
        }
    }
    
}
