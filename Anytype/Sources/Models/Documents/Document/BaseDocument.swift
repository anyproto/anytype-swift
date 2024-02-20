import Services
import Combine
import AnytypeCore
import Foundation

final class BaseDocument: BaseDocumentProtocol {
    var syncStatus: AnyPublisher<SyncStatus, Never> { $_syncStatus.eraseToAnyPublisher() }
    @Published private var _syncStatus: SyncStatus = .unknown
    
    var childrenPublisher: AnyPublisher<[BlockInformation], Never> { $_children.eraseToAnyPublisher() }
    @Published private var _children = [BlockInformation]()
    
    private var _resetBlocksSubject = PassthroughSubject<Set<String>, Never>()
    var resetBlocksSubject: PassthroughSubject<Set<String>, Never> { _resetBlocksSubject }
    
    let objectId: String
    private(set) var isOpened = false
    let forPreview: Bool
    
    let infoContainer: InfoContainerProtocol = InfoContainer()
    let relationLinksStorage: RelationLinksStorageProtocol = RelationLinksStorage()
    let restrictionsContainer: ObjectRestrictionsContainer = ObjectRestrictionsContainer()
    let detailsStorage = ObjectDetailsStorage()
    
    var objectRestrictions: ObjectRestrictions { restrictionsContainer.restrinctions }
    private let objectLifecycleService: ObjectLifecycleServiceProtocol
    private let eventsListener: EventsListenerProtocol
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
            relationValuesIsLocked: relationValuesIsLocked,
            storage: detailsStorage
        )
    }
    
    var isLocked: Bool {
        return infoContainer.get(id: objectId)?.isLocked ?? false
    }
    
    var relationValuesIsLocked: Bool {
        return isLocked || isArchived || objectRestrictions.objectRestriction.contains(.details)
    }
    
    var relationsListIsLocked: Bool {
        return isLocked || isArchived || objectRestrictions.objectRestriction.contains(.relations)
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
            .compactMap { [weak self, objectId] in
                self?.detailsStorage.get(id: objectId)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    init(
        objectId: String,
        forPreview: Bool,
        objectLifecycleService: ObjectLifecycleServiceProtocol,
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
        
        self.objectLifecycleService = objectLifecycleService
        self.relationBuilder = RelationsBuilder()
        self.relationDetailsStorage = relationDetailsStorage
        self.objectTypeProvider = objectTypeProvider
        
        setup()
    }
    
    deinit {
        guard !forPreview, isOpened, UserDefaultsConfig.usersId.isNotEmpty else { return }
        Task.detached(priority: .userInitiated) { [objectLifecycleService, objectId] in
            try await objectLifecycleService.close(contextId: objectId)
        }
    }
    
    // MARK: - BaseDocumentProtocol
    
    var spaceId: String {
        details?.spaceId ?? ""
    }
    
    @MainActor
    func open() async throws {
        if isOpened {
            return
        }
        guard !forPreview else {
            anytypeAssertionFailure("Document created for preview. You should use openForPreview() method.")
            return
        }
        let model = try await objectLifecycleService.open(contextId: objectId)
        setupView(model)
    }
    
    @MainActor
    func openForPreview() async throws {
        guard forPreview else {
            anytypeAssertionFailure("Document created for handling. You should use open() method.")
            return
        }
        let model = try await objectLifecycleService.openForPreview(contextId: objectId)
        setupView(model)
    }
    
    @MainActor
    func close() async throws {
        guard !forPreview, isOpened, UserDefaultsConfig.usersId.isNotEmpty else { return }
        try await objectLifecycleService.close(contextId: objectId)
        isOpened = false
    }
    
    var children: [BlockInformation] {
        return _children
    }
    
    var isEmpty: Bool {
        let filteredBlocks = _children.filter { $0.isFeaturedRelations || $0.isText }
        
        if filteredBlocks.count > 0 { return false }
        let allTextChilds = _children.filter(\.isText)
        
        if allTextChilds.count > 1 { return false }
        
        return allTextChilds.first?.content.isEmpty ?? false
    }
    
    // MARK: - Private methods
    private func setup() {
        eventsListener.onUpdatesReceive = { [weak self] updates in
            DispatchQueue.main.async { [weak self] in
                self?.triggerSync(updates: updates)
            }
        }
        if !forPreview {
            eventsListener.startListening()
        }
    }
    
    private func reorderChilder() {
        guard let model = infoContainer.get(id: objectId) else {
            return
        }
        let flatten = model.flatChildrenTree(container: infoContainer)
        _children = flatten
    }
    
    private func triggerSync(updates: [DocumentUpdate]) {
        for update in updates.merged {
            guard update.hasUpdate else { return }
            
            switch update {
            case .general:
                infoContainer.publishAllValues()
                reorderChilder()
            case .children(let blockIds):
                blockIds.forEach { infoContainer.publishValue(for: $0) }
                _resetBlocksSubject.send(blockIds)
                reorderChilder()
            case .blocks(let blockIds):
                blockIds.forEach { infoContainer.publishValue(for: $0) }
                _resetBlocksSubject.send(blockIds)
            case .unhandled(let blockIds):
                blockIds.forEach { infoContainer.publishValue(for: $0) }
            case .syncStatus:
                break
            case .details:
                break // Sync will be send always
            }
        }
        
        parsedRelationsSubject.send(parsedRelations)
    
        sync = ()
    }
    
    private func setupView(_ model: ObjectViewModel) {
        viewModelSetter.objectViewUpdate(model)
        isOpened = true
        triggerSync(updates: [.general])
    }
}

private extension Array where Element == DocumentUpdate {
    var merged: Self {
        if contains(.general) { return [.general] }
        var childIds = Set<String>()
        var blockIds = Set<String>()
        var unhandled = Set<String>()
        
        var output = [DocumentUpdate]()
        
        self.forEach { update in
            switch update {
            case let .blocks(ids):
                blockIds.formUnion(ids)
            case let .children(ids):
                childIds.formUnion(ids)
            case let .unhandled(ids):
                unhandled.formUnion(ids)
            case .details, .syncStatus:
                output.append(update)
            case .general:
                break
            }
        }
        
        
        if childIds.isNotEmpty {
            childIds.formUnion(blockIds)
            output.append(.children(blockIds: childIds))
        } else {
            if blockIds.isNotEmpty {
                output.append(.blocks(blockIds: blockIds))
            }
        }
        
        if unhandled.isNotEmpty {
            output.append(.unhandled(blockIds: unhandled))
        }
        
        return output
    }
}
