import Services
import Combine
import AnytypeCore
import Foundation

final class BaseDocument: BaseDocumentProtocol {
    var updatePublisher: AnyPublisher<DocumentUpdate, Never> { updateSubject.eraseToAnyPublisher() }
    let objectId: BlockId
    private(set) var isOpened = false
    let forPreview: Bool

    let infoContainer: InfoContainerProtocol = InfoContainer()
    let relationLinksStorage: RelationLinksStorageProtocol = RelationLinksStorage()
    let restrictionsContainer: ObjectRestrictionsContainer = ObjectRestrictionsContainer()
    let detailsStorage = ObjectDetailsStorage()
    
    var objectRestrictions: ObjectRestrictions { restrictionsContainer.restrinctions }

    private let blockActionsService: BlockActionsServiceSingleProtocol
    private let eventsListener: EventsListenerProtocol
    private let updateSubject = PassthroughSubject<DocumentUpdate, Never>()
    private let relationBuilder: RelationsBuilder
    private let relationDetailsStorage: RelationDetailsStorageProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let viewModelSetter: DocumentViewModelSetterProtocol
    
    private var subscriptions = [AnyCancellable]()
    
    @Published private var sync: Void?
    var syncPublisher: AnyPublisher<Void, Never> {
        return $sync.compactMap { $0 }.eraseToAnyPublisher()
    }
    
    // MARK: - State
    private var parsedRelationsSubject = CurrentValueSubject<ParsedRelations, Never>(.empty)
    var parsedRelationsPublisher: AnyPublisher<ParsedRelations, Never> {
        parsedRelationsSubject.eraseToAnyPublisher()
    }
    // All places, where parsedRelations used, should be subscribe on parsedRelationsPublisher.
    var parsedRelations: ParsedRelations {
        let objectRelationsDetails = relationDetailsStorage.relationsDetails(
            for: relationLinksStorage.relationLinks,
            spaceId: spaceId
        )
        let recommendedRelations = relationDetailsStorage.relationsDetails(for: details?.objectType.recommendedRelations ?? [], spaceId: spaceId)
        let typeRelationsDetails = recommendedRelations.filter { !objectRelationsDetails.contains($0) }
        return relationBuilder.parsedRelations(
            relationsDetails: objectRelationsDetails,
            typeRelationsDetails: typeRelationsDetails,
            objectId: objectId,
            isObjectLocked: isLocked || isArchived,
            storage: detailsStorage
        )
    }
    
    var isLocked: Bool {
        return infoContainer.get(id: objectId)?.isLocked ?? false
    }
    
    var isArchived: Bool {
        return details?.isArchived ?? false
    }
    
    var details: ObjectDetails? {
        detailsStorage.get(id: objectId)
    }
    
    var detailsPublisher: AnyPublisher<ObjectDetails, Never> {
        syncPublisher
            .receiveOnMain()
            .compactMap { [weak self, objectId] in self?.detailsStorage.get(id: objectId) }
            .eraseToAnyPublisher()
    }
    
    init(
        objectId: BlockId,
        forPreview: Bool,
        blockActionsService: BlockActionsServiceSingleProtocol,
        relationDetailsStorage: RelationDetailsStorageProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol
    ) {
        self.objectId = objectId
        self.forPreview = forPreview
       
        self.eventsListener = EventsListener(
            objectId: objectId,
            infoContainer: infoContainer,
            relationLinksStorage: relationLinksStorage,
            restrictionsContainer: restrictionsContainer,
            detailsStorage: detailsStorage
        )
        
        self.viewModelSetter = DocumentViewModelSetter(
            detailsStorage: detailsStorage,
            relationLinksStorage: relationLinksStorage,
            restrictionsContainer: restrictionsContainer,
            infoContainer: infoContainer
        )
        
        self.blockActionsService = blockActionsService
        self.relationBuilder = RelationsBuilder()
        self.relationDetailsStorage = relationDetailsStorage
        self.objectTypeProvider = objectTypeProvider
        
        setup()
    }
    
    deinit {
        guard !forPreview, isOpened, UserDefaultsConfig.usersId.isNotEmpty else { return }
        Task.detached(priority: .userInitiated) { [blockActionsService, objectId] in
            try await blockActionsService.close(contextId: objectId)
        }
    }

    // MARK: - BaseDocumentProtocol
    
    var spaceId: String {
        details?.spaceId ?? ""
    }
    
    @MainActor
    func open() async throws {
        if isOpened {
            updateSubject.send(.general)
            return
        }
        guard !forPreview else {
            anytypeAssertionFailure("Document created for preview. You should use openForPreview() method.")
            return
        }
        let model = try await blockActionsService.open(contextId: objectId)
        setupView(model)
    }
    
    @MainActor
    func openForPreview() async throws {
        guard forPreview else {
            anytypeAssertionFailure("Document created for handling. You should use open() method.")
            return
        }
        let model = try await blockActionsService.openForPreview(contextId: objectId)
        setupView(model)
    }
    
    @MainActor
    func close() async throws {
        guard !forPreview, isOpened, UserDefaultsConfig.usersId.isNotEmpty else { return }
        try await blockActionsService.close(contextId: objectId)
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
                self?.triggerSync()
            }
        }
        if !forPreview {
            eventsListener.startListening()
        }
        
        Publishers
            .CombineLatest3(
                relationDetailsStorage.relationsDetailsPublisher,
                // Depends on different objects: relation options and relation objects
                // Subscriptions for each object will be complicated. Subscribes to any document updates.
                objectTypeProvider.syncPublisher,
                updatePublisher
            )
            .map { [weak self] _ -> ParsedRelations in
                guard let self = self else { return .empty }
                return self.parsedRelations
            }
            .removeDuplicates()
            .receiveOnMain()
            .sink { [weak self] in
                self?.parsedRelationsSubject.send($0)
                // Update block relation when relation is deleted or installed
                self?.updateSubject.send(.general)
            }
            .store(in: &subscriptions)
    }
    
    private func triggerSync() {
        sync = ()
    }
    
    private func setupView(_ model: ObjectViewModel) {
        viewModelSetter.objectViewUpdate(model)
        isOpened = true
        updateSubject.send(.general)
        triggerSync()
    }
}
