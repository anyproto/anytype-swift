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
     
    private let infoContainer: InfoContainerProtocol
    
    private let middlewareConverter: MiddlewareEventConverter
    private let localConverter: LocalEventConverter
    private let mentionMarkupEventProvider: MentionMarkupEventProvider
    
    private var subscription: AnyCancellable?
    
    // MARK: - Initializers
    
    init(
        objectId: BlockId,
        infoContainer: InfoContainerProtocol,
        relationStorage: RelationsMetadataStorageProtocol,
        restrictionsContainer: ObjectRestrictionsContainer
    ) {
        self.objectId = objectId
        self.infoContainer = infoContainer
        
        let informationCreator = BlockInformationCreator(
            validator: BlockValidator(),
            infoContainer: infoContainer
        )
        self.middlewareConverter = MiddlewareEventConverter(
            infoContainer: infoContainer,
            relationStorage: relationStorage,
            informationCreator: informationCreator,
            restrictionsContainer: restrictionsContainer
        )
        self.localConverter = LocalEventConverter(
            infoContainer: infoContainer
        )
        self.mentionMarkupEventProvider = MentionMarkupEventProvider(
            objectId: objectId,
            infoContainer: infoContainer
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
                    container: infoContainer,
                    id: objectId
                )
            }
            
            onUpdateReceive?(update)
        }
    }
}
