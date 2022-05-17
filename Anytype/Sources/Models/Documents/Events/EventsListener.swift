import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import AnytypeCore

final class EventsListener: EventsListenerProtocol {
    
    // MARK: - Internal variables
    
    var onUpdateReceive: ((DocumentUpdate) -> Void)?
        
    // MARK: - Private variables
    
    private let objectId: AnytypeId
     
    private let infoContainer: InfoContainerProtocol
    
    private let middlewareConverter: MiddlewareEventConverter
    private let localConverter: LocalEventConverter
    private let mentionMarkupEventProvider: MentionMarkupEventProvider
    
    private var subscription: AnyCancellable?
    
    // MARK: - Initializers
    
    init(
        objectId: AnytypeId,
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
            .filter { $0.contextId == self.objectId.value }
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

        updates
            .filteredUpdates
            .forEach { update in
            if update.hasUpdate {
                IndentationBuilder.build(
                    container: infoContainer,
                    id: objectId.value
                )
            }
            
            onUpdateReceive?(update)
        }
    }
}

private extension Array where Element == DocumentUpdate {
    var filteredUpdates: Self {
        guard contains(.general) else {
            return self
        }

        return filter { element in
            switch element {
            case .general, .changeType:
                return true
            case .syncStatus, .blocks, .details, .dataSourceUpdate, .header:
                return false
            }
        }
    }
}
