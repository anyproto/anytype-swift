import Foundation
import Combine
import Services
import ProtobufMessages
import AnytypeCore

actor EventsListener: EventsListenerProtocol {
    
    // MARK: - Internal variables
    
    var onUpdatesReceive: (([DocumentUpdate]) -> Void)?
        
    // MARK: - Private variables
    
    private let objectId: String
     
    private let infoContainer: any InfoContainerProtocol
    
    private let middlewareConverter: MiddlewareEventConverter
    private let localConverter: LocalEventConverter
    private let mentionMarkupEventProvider: MentionMarkupEventProvider
    
    private var subscriptions = [AnyCancellable]()
    
    // MARK: - Initializers
    
    init(
        objectId: String,
        infoContainer: some InfoContainerProtocol,
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
    }
    
    // MARK: - EventsListenerProtocol
    
    nonisolated
    func startListening() {
        Task {
            await startListeningInternal()
        }
    }
    
    nonisolated
    func stopListening() {
        Task {
            await stopListeningInternal()
        }
    }
    
    nonisolated
    func setOnUpdateReceice(_ closure: @escaping @Sendable ([DocumentUpdate]) -> Void) {
        Task {
            await setOnUpdateReceiceInternal(closure)
        }
    }
    
    // MARK: - Private
    
    private func startListeningInternal() {
        subscribeMiddlewareEvents()
    }
    
    private func stopListeningInternal() {
        subscriptions = []
    }
    
    
    private func setOnUpdateReceiceInternal(_ closure: @escaping ([DocumentUpdate]) -> Void) {
        onUpdatesReceive = closure
    }
    
    private func subscribeMiddlewareEvents() {
        EventBunchSubscribtion.default.addHandler { [weak self] events in
            guard events.contextId == self?.objectId else { return }
            await self?.handle(events: events)
        }.store(in: &subscriptions)
    }
    
    private func handle(events: EventsBunch) {
        let middlewareUpdates = events.middlewareEvents.compactMap(\.value).compactMap { middlewareConverter.convert($0) }
        let localUpdates = events.localEvents.compactMap { localConverter.convert($0) }
        let markupUpdates = mentionMarkupEventProvider.updateMentionsEvent()

        let builderChangedIds = IndentationBuilder.build(
            container: infoContainer,
            id: objectId
        )
        let builderUpdates: [DocumentUpdate] = builderChangedIds.map { .block(blockId: $0) }
    
        let updates = middlewareUpdates + markupUpdates + localUpdates + builderUpdates
        receiveUpdates(updates.filteredUpdates)
    }
    
    private func receiveUpdates(_ updates: [DocumentUpdate]) {
        onUpdatesReceive?(updates)
    }
}

private extension Array where Element == DocumentUpdate {
    var filteredUpdates: Self {
        contains(.general) ? [.general] : self
    }
}
