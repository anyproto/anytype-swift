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
    
    private let middlewareConverter: MiddlewareEventConverter
    private let localConverter: LocalEventConverter
    private let mentionMarkupEventProvider: MentionMarkupEventProvider
    
    private var subscription: AnyCancellable?
    
    // MARK: - Initializers
    
    init(
        objectId: BlockId,
        blocksContainer: BlockContainerModelProtocol,
        relationStorage: RelationsMetadataStorageProtocol
    ) {
        self.objectId = objectId
        self.blocksContainer = blocksContainer
        
        let informationCreator = BlockInformationCreator(
            validator: BlockValidator(),
            blocksContainer: blocksContainer
        )
        self.middlewareConverter = MiddlewareEventConverter(
            blocksContainer: blocksContainer,
            relationStorage: relationStorage,
            informationCreator: informationCreator
        )
        self.localConverter = LocalEventConverter(
            blocksContainer: blocksContainer
        )
        self.mentionMarkupEventProvider = MentionMarkupEventProvider(
            objectId: objectId,
            blocksContainer: blocksContainer
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
            .filter { $0.contextId == self.objectId }
            .sink { [weak self] events in
                self?.handle(events: events)
            }
    }
    
    private func handle(events: EventsBunch) {
        let middlewareUpdates = events.middlewareEvents.compactMap(\.value).compactMap { middlewareConverter.convert($0) }
        let localUpdates = events.localEvents.compactMap { localConverter.convert($0) }
        let markupUpdates = [mentionMarkupEventProvider.updateMentionsEvent()].compactMap { $0 }
        let dataSourceUpdates = events.dataSourceEvents.compactMap { localConverter.convert($0) }

        var updates = middlewareUpdates + markupUpdates + localUpdates

        if dataSourceUpdates.isNotEmpty {
            updates.append(.dataSourceUpdate)
        }

        updates.forEach { update in
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
