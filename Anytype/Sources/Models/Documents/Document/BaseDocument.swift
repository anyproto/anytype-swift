import BlocksModels
import Combine
import AnytypeCore
import Foundation

final class BaseDocument: BaseDocumentProtocol {
    var updatePublisher: AnyPublisher<DocumentUpdate, Never> { updateSubject.eraseToAnyPublisher() }
    let objectId: BlockId
    private(set) var isOpened = false

    let infoContainer: InfoContainerProtocol = InfoContainer()
    let relationLinksStorage: RelationLinksStorageProtocol = RelationLinksStorage()
    let restrictionsContainer: ObjectRestrictionsContainer = ObjectRestrictionsContainer()
    
    var objectRestrictions: ObjectRestrictions { restrictionsContainer.restrinctions }

    private let blockActionsService: BlockActionsServiceSingleProtocol
    private let eventsListener: EventsListener
    private let updateSubject = PassthroughSubject<DocumentUpdate, Never>()
    private let relationBuilder = RelationsBuilder()
    private let detailsStorage = ObjectDetailsStorage.shared
    private let relationDetailsStorage = ServiceLocator.shared.relationDetailsStorage()

    private var subscriptions = [AnyCancellable]()
    
    // MARK: - State
    private var parsedRelationsSubject = CurrentValueSubject<ParsedRelations, Never>(.empty)
    var parsedRelationsPublisher: AnyPublisher<ParsedRelations, Never> {
        parsedRelationsSubject.eraseToAnyPublisher()
    }
    // All places, where parsedRelations used, should be subscribe on parsedRelationsPublisher.
    var parsedRelations: ParsedRelations {
        return relationBuilder.parsedRelations(
            relationsDetails: relationDetailsStorage.relationsDetails(
                for: relationLinksStorage.relationLinks
            ),
            objectId: objectId,
            isObjectLocked: isLocked
        )
    }
    
    @Published var isLocked = false
    var isLockedPublisher: AnyPublisher<Bool, Never> {
        $isLocked.eraseToAnyPublisher()
    }
    
    var details: ObjectDetails? {
        detailsStorage.get(id: objectId)
    }
    
    var detailsPublisher: AnyPublisher<ObjectDetails, Never> {
        detailsStorage.publisherFor(id: objectId)
            .receiveOnMain()
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    init(objectId: BlockId) {
        self.objectId = objectId
        
        self.eventsListener = EventsListener(
            objectId: objectId,
            infoContainer: infoContainer,
            relationLinksStorage: relationLinksStorage,
            restrictionsContainer: restrictionsContainer
        )
        
        self.blockActionsService = ServiceLocator.shared.blockActionsServiceSingle(contextId: objectId)
        
        setup()
    }
    
    deinit {
        Task.detached(priority: .userInitiated) { [blockActionsService] in
            try await blockActionsService.close()
        }
    }

    // MARK: - BaseDocumentProtocol
    
    @MainActor
    func open() async throws {
        try await blockActionsService.open()
        isOpened = true
    }
    
    @MainActor
    func openForPreview() async throws {
        try await blockActionsService.openForPreview()
        isOpened = true
    }
    
    @MainActor
    func close() async throws {
        try await blockActionsService.close()
        isOpened = false
    }
    
    var children: [BlockInformation] {
        guard let model = infoContainer.get(id: objectId) else {
            return []
        }
        return model.flatChildrenTree(container: infoContainer)
    }

    var isEmpty: Bool {
        let filteredBlocks = children.filter { $0.isFeaturedRelations || $0.isText }

        if filteredBlocks.count > 0 { return false }
        let allTextChilds = children.filter(\.isText)

        if allTextChilds.count > 1 { return false }

        return allTextChilds.first?.content.isEmpty ?? false
    }

    // MARK: - Private methods
    private func setup() {
        eventsListener.onUpdateReceive = { [weak self] update in
            guard update.hasUpdate else { return }
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                self?.updateSubject.send(update)
            }
        }
        eventsListener.startListening()
                
        infoContainer.publisherFor(id: objectId)
            .compactMap { $0?.isLocked }
            .removeDuplicates()
            .receiveOnMain()
            .assign(to: &$isLocked)
        
        Publishers
            .CombineLatest(
                relationDetailsStorage.relationsDetailsPublisher,
                // Depends on different objects: relation options and relation objects
                // Subscriptions for each object will be complicated. Subscribes to any document updates.
                updatePublisher
            )
            .map { [weak self] _ in
                guard let self = self else { return .empty }
                let data = self.relationBuilder.parsedRelations(
                    relationsDetails: self.relationDetailsStorage.relationsDetails(
                        for: self.relationLinksStorage.relationLinks
                    ),
                    objectId: self.objectId,
                    isObjectLocked: self.isLocked
                )
                return data
            }
            .removeDuplicates()
            .receiveOnMain()
            .sink { [weak self] in
                self?.parsedRelationsSubject.send($0)
                if FeatureFlags.fixUpdateRelationBlock {
                    // Update block relation when relation is deleted or installed
                    self?.updateSubject.send(.general)
                }
            }
            .store(in: &subscriptions)
    }
}
