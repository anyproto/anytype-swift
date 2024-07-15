import Services
import Combine
import AnytypeCore
import Foundation

final class BaseDocument: BaseDocumentProtocol {
    
    // MARK: - State from Containers
    
    var isLocked: Bool { infoContainer.get(id: objectId)?.isLocked ?? false }
    var details: ObjectDetails? { detailsStorage.get(id: objectId) }
    var objectRestrictions: ObjectRestrictions { restrictionsContainer.restrinctions }
    
    // MARK: - Local state
    let objectId: String
    let forPreview: Bool
    @Atomic
    private(set) var children = [BlockInformation]()
    @Atomic
    private(set) var isOpened = false
    @Atomic
    private(set) var parsedRelations = ParsedRelations.empty
    @Atomic
    private(set) var permissions = ObjectPermissions()
    
    let infoContainer: any InfoContainerProtocol
    let relationLinksStorage: any RelationLinksStorageProtocol
    let restrictionsContainer: ObjectRestrictionsContainer
    let detailsStorage: ObjectDetailsStorage
    
    private let objectLifecycleService: any ObjectLifecycleServiceProtocol
    private let eventsListener: any EventsListenerProtocol
    @Injected(\.relationsBuilder)
    private var relationBuilder: any RelationsBuilderProtocol
    @Injected(\.syncStatusStorage)
    private var syncStatusStorage: any SyncStatusStorageProtocol
    private let relationDetailsStorage: any RelationDetailsStorageProtocol
    private let objectTypeProvider: any ObjectTypeProviderProtocol
    private let accountParticipantsStorage: any AccountParticipantsStorageProtocol
    private let viewModelSetter: any DocumentViewModelSetterProtocol
    
    // MARK: - Local private state
    @Atomic
    private var participantIsEditor: Bool = false
    private var subscriptions = [AnyCancellable]()
    @Atomic
    private var parsedRelationDependedDetailsEvents = [DocumentUpdate]()
    
    // MARK: - Sync Handle
    var syncPublisher: AnyPublisher<[BaseDocumentUpdate], Never> {
        return syncSubject
            .merge(with: Just(isOpened ? [.general] : []))
            .filter { $0.isNotEmpty }
            .eraseToAnyPublisher()
    }
    private var syncSubject = PassthroughSubject<[BaseDocumentUpdate], Never>()
    
    private var syncStatusSubject = PassthroughSubject<SyncStatus, Never>()
    var syncStatusPublisher: AnyPublisher<SyncStatus, Never> { syncStatusSubject.eraseToAnyPublisher() }
        
    init(
        objectId: String,
        forPreview: Bool,
        objectLifecycleService: some ObjectLifecycleServiceProtocol,
        relationDetailsStorage: some RelationDetailsStorageProtocol,
        objectTypeProvider: some ObjectTypeProviderProtocol,
        accountParticipantsStorage: some AccountParticipantsStorageProtocol,
        eventsListener: some EventsListenerProtocol,
        viewModelSetter: some DocumentViewModelSetterProtocol,
        infoContainer: some InfoContainerProtocol,
        relationLinksStorage: some RelationLinksStorageProtocol,
        restrictionsContainer: ObjectRestrictionsContainer,
        detailsStorage: ObjectDetailsStorage
    ) {
        self.objectId = objectId
        self.forPreview = forPreview
        self.eventsListener = eventsListener
        self.viewModelSetter = viewModelSetter
        self.objectLifecycleService = objectLifecycleService
        self.relationDetailsStorage = relationDetailsStorage
        self.objectTypeProvider = objectTypeProvider
        self.accountParticipantsStorage = accountParticipantsStorage
        self.infoContainer = infoContainer
        self.relationLinksStorage = relationLinksStorage
        self.restrictionsContainer = restrictionsContainer
        self.detailsStorage = detailsStorage
        
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
    
    var isEmpty: Bool {
        let filteredBlocks = children.filter { $0.isFeaturedRelations || $0.isText }
        
        if filteredBlocks.count > 0 { return false }
        let allTextChilds = children.filter(\.isText)
        
        if allTextChilds.count > 1 { return false }
        
        return allTextChilds.first?.content.isEmpty ?? false
    }
    
    func subscibeFor(update: [BaseDocumentUpdate]) -> AnyPublisher<[BaseDocumentUpdate], Never> {
        return syncSubject
            .merge(with: Just(isOpened ? update : []))
            .map { syncUpdate in
                if syncUpdate.contains(.general) {
                    return update
                }
                return update.filter { syncUpdate.contains($0) }
            }
            .filter { $0.isNotEmpty }
            .eraseToAnyPublisher()
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
        children = flatten
    }
    
    private func triggerSync(updates: [DocumentUpdate]) {
        
        var docUpdates = updates.flatMap { update -> [BaseDocumentUpdate] in
            switch update {
            case .general:
                return [.general]
            case .block(let blockId):
                return [.block(blockId: blockId)]
            case .children(let blockId):
                return [.block(blockId: blockId), .children]
            case .details(let id):
                return [.details(id: id)]
            case .unhandled(let blockId):
                return [.unhandled(blockId: blockId)]
            case .relationLinks, .restrictions, .close:
                return [] // A lot of casese for update relations
            }
        }
        
        let permissioUpdates = triggerUpdatePermissions(updates: updates)
        docUpdates.append(contentsOf: permissioUpdates)
        
        let relationUpdates = triggerUpdateRelations(updates: updates, permissionsChanged: permissioUpdates.isNotEmpty)
        docUpdates.append(contentsOf: relationUpdates)
        
        if updates.contains(where: { $0 == .general || $0.isChildren }) {
            reorderChilder()
        }
        
        if updates.contains(.close) {
            isOpened = false
        }
        
        if docUpdates.isNotEmpty {
            syncSubject.send(docUpdates)
        }
    }
    
    @MainActor
    private func setupView(_ model: ObjectViewModel) {
        viewModelSetter.objectViewUpdate(model)
        isOpened = true
        setupSubscriptions()
        triggerSync(updates: [.general])
    }

    @MainActor
    private func setupSubscriptions() {
        Task { @MainActor in
            let syncStatusPublisher = await syncStatusStorage.statusPublisher(spaceId: spaceId).sink { [weak self] info in
                guard let info else { return }
                self?.syncStatusSubject.send(info.status)
            }
            
            syncStatusPublisher.store(in: &subscriptions)
        }
        
        accountParticipantsStorage.canEditPublisher(spaceId: spaceId).sink { [weak self] canEdit in
            self?.participantIsEditor = canEdit
            self?.triggerSync(updates: [.restrictions])
        }
        .store(in: &subscriptions)
        
        relationDetailsStorage.relationsDetailsPublisher(spaceId: spaceId)
            .sink { [weak self] details in
                guard let self else { return }
                let contains = details.contains { self.relationLinksStorage.contains(relationKeys: [$0.key]) }
                if contains {
                    triggerSync(updates: [.relationLinks])
                }
            }
            .store(in: &subscriptions)
    }
    
    private func triggerUpdateRelations(updates: [DocumentUpdate], permissionsChanged: Bool) -> [BaseDocumentUpdate] {
        
        var updatesForRelations: [DocumentUpdate] = [.general, .relationLinks, .details(id: objectId)]
        updatesForRelations.append(contentsOf: parsedRelationDependedDetailsEvents)
        
        guard updates.contains(where: { updatesForRelations.contains($0) }) || permissionsChanged else { return [] }
        
        let objectRelationsDetails = relationDetailsStorage.relationsDetails(
            for: relationLinksStorage.relationLinks,
            spaceId: spaceId
        )
        let recommendedRelations = relationDetailsStorage.relationsDetails(for: details?.objectType.recommendedRelations ?? [], spaceId: spaceId)
        let typeRelationsDetails = recommendedRelations.filter { !objectRelationsDetails.contains($0) }
        let newRelations = relationBuilder.parsedRelations(
            relationsDetails: objectRelationsDetails,
            typeRelationsDetails: typeRelationsDetails,
            objectId: objectId,
            relationValuesIsLocked: !permissions.canEditRelationValues,
            storage: detailsStorage
        )
        
        let dependedObjectIds = newRelations.all.flatMap(\.dependedObjects)
        parsedRelationDependedDetailsEvents = dependedObjectIds.map { .details(id: $0) }
        if parsedRelations != newRelations {
            parsedRelations = newRelations
            return [.relations]
        }
        
        return []
    }
    
    private func triggerUpdatePermissions(updates: [DocumentUpdate]) -> [BaseDocumentUpdate] {
        let updatesForPermissions: [DocumentUpdate] = [.general, .details(id: objectId), .block(blockId: objectId), .restrictions]
        guard updates.contains(where: { updatesForPermissions.contains($0) }) else { return [] }
        
        let newPermissios = ObjectPermissions(
            details: details ?? ObjectDetails(id: ""),
            isLocked: isLocked,
            participantCanEdit: participantIsEditor,
            objectRestrictions: objectRestrictions.objectRestriction
        )
        
        if permissions != newPermissios {
            permissions = newPermissios
            return [.permissions]
        }
        
        return []
    }
}
