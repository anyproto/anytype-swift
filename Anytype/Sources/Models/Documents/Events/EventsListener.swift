import Foundation
import Combine
import Services
import ProtobufMessages
import AnytypeCore

final class EventsListener: EventsListenerProtocol {
    
    // MARK: - Internal variables
    
    var onUpdateReceive: ((DocumentUpdate) -> Void)?
        
    // MARK: - Private variables
    
    private let objectId: BlockId
     
    private let infoContainer: InfoContainerProtocol
    
    private let middlewareConverter: MiddlewareEventConverter
    private let localConverter: LocalEventConverter
    private let mentionMarkupEventProvider: MentionMarkupEventProvider
    private let relationEventConverter: RelationEventConverter
    
    private var subscriptions = [AnyCancellable]()
    
    // MARK: - Initializers
    
    init(
        objectId: BlockId,
        infoContainer: InfoContainerProtocol,
        relationLinksStorage: RelationLinksStorageProtocol,
        restrictionsContainer: ObjectRestrictionsContainer,
        detailsStorage: ObjectDetailsStorage
    ) {
        self.objectId = objectId
        self.infoContainer = infoContainer
        
        let informationCreator = BlockInformationCreator(
            validator: BlockValidator(),
            infoContainer: infoContainer
        )
        self.middlewareConverter = MiddlewareEventConverter(
            infoContainer: infoContainer,
            relationLinksStorage: relationLinksStorage,
            informationCreator: informationCreator,
            detailsStorage: detailsStorage,
            restrictionsContainer: restrictionsContainer
        )
        self.localConverter = LocalEventConverter(
            infoContainer: infoContainer
        )
        self.mentionMarkupEventProvider = MentionMarkupEventProvider(
            objectId: objectId,
            infoContainer: infoContainer,
            detailsStorage: detailsStorage
        )
        self.relationEventConverter = RelationEventConverter(relationLinksStorage: relationLinksStorage)
    }
    
    // MARK: - EventsListenerProtocol
    
    func startListening() {
        subscribeMiddlewareEvents()
        subscribeRelationEvents()
    }
    
    func stopListening() {
        subscriptions = []
    }
    
    private func subscribeMiddlewareEvents() {
        EventBunchSubscribtion.default.addHandler { [weak self] events in
            guard events.contextId == self?.objectId else { return }
            await self?.handle(events: events)
        }.store(in: &subscriptions)
    }
    
    private func subscribeRelationEvents() {
        let subscription = NotificationCenter.Publisher(
            center: .default,
            name: .relationEvent,
            object: nil
        )
            .compactMap { $0.object as? RelationEventsBunch }
            .receiveOnMain()
            .sink { [weak self] eventsBunch in
                self?.handleRelation(eventsBunch: eventsBunch)
            }
        subscriptions.append(subscription)
    }
    
    @MainActor
    private func handle(events: EventsBunch) {
        let middlewareUpdates = events.middlewareEvents.compactMap(\.value).compactMap { middlewareConverter.convert($0) }
        let localUpdates = events.localEvents.compactMap { localConverter.convert($0) }
        let markupUpdates = [mentionMarkupEventProvider.updateMentionsEvent()].compactMap { $0 }
        let dataSourceUpdates = events.dataSourceEvents.compactMap { localConverter.convert($0) }

        var updates = middlewareUpdates + markupUpdates + localUpdates

        if dataSourceUpdates.isNotEmpty {
            updates.append(.dataSourceUpdate)
        }

        receiveUpdates(updates)
    }
    
    private func handleRelation(eventsBunch: RelationEventsBunch) {
        let updates = eventsBunch.events.compactMap { relationEventConverter.convert($0) }
        receiveUpdates(updates)
    }
    
    private func receiveUpdates(_ updates: [DocumentUpdate]) {
        if updates.contains(where: (\.hasUpdate)) {
            IndentationBuilder.build(
                container: infoContainer,
                id: objectId
            )
        }
        
        updates
            .filteredUpdates
            .forEach { update in
            onUpdateReceive?(update)
        }
    }
}

private extension Array where Element == DocumentUpdate {
    var filteredUpdates: Self {
        var newUpdates = filter {
            if case .blocks = $0 {
                return false
            }

            return true
        }

        var blockIdsUpdates = Set<BlockId>()

        forEach {
            if case let .blocks(blocksSet) = $0 {
                blocksSet.forEach { blockIdsUpdates.insert($0) }
            }
        }
        if blockIdsUpdates.count > 0 {
            newUpdates.append(.blocks(blockIds: blockIdsUpdates))
        }

        guard contains(.general) else {
            return newUpdates
        }

        return [.general]
    }
}
