import Services
import Combine
import AnytypeCore
import Foundation

final class BaseDocument: BaseDocumentProtocol, @unchecked Sendable {
    
    // MARK: - State from Containers
    
    var isLocked: Bool { infoContainer.get(id: objectId)?.isLocked ?? false }
    var details: ObjectDetails? { detailsStorage.get(id: objectId) }
    var objectRestrictions: ObjectRestrictions { restrictionsContainer.restrictions }
    
    // MARK: - Local state
    let objectId: String
    let spaceId: String
    let mode: DocumentMode
    
    @Atomic
    private(set) var children = [BlockInformation]()
    @Atomic
    private(set) var isOpened = false
    @Atomic
    private(set) var parsedRelations = ParsedRelations.empty
    @Atomic
    private(set) var permissions = ObjectPermissions()
    @Atomic
    private(set) var syncStatus: SyncStatus?
    
    let infoContainer: any InfoContainerProtocol
    let restrictionsContainer: ObjectRestrictionsContainer
    let detailsStorage: ObjectDetailsStorage
    
    private let objectLifecycleService: any ObjectLifecycleServiceProtocol
    private let eventsListener: any EventsListenerProtocol
    @Injected(\.relationsBuilder)
    private var relationBuilder: any RelationsBuilderProtocol
    @Injected(\.syncStatusStorage)
    private var syncStatusStorage: any SyncStatusStorageProtocol
    @Injected(\.historyVersionsService)
    private var historyVersionsService: any HistoryVersionsServiceProtocol
    private let propertyDetailsStorage: any PropertyDetailsStorageProtocol
    private let objectTypeProvider: any ObjectTypeProviderProtocol
    private let accountParticipantsStorage: any AccountParticipantsStorageProtocol
    private let viewModelSetter: any DocumentViewModelSetterProtocol

    private let basicUserInfoStorage: any BasicUserInfoStorageProtocol = Container.shared.basicUserInfoStorage()
    
    
    // MARK: - Local private state
    @Atomic
    private var participantIsEditor: Bool = false
    private var subscriptions = [AnyCancellable]()
    @Atomic
    private var parsedRelationDependedDetailsEvents = [DocumentUpdate]()
    private var openTask: Task<Void, any Error>?
    
    // MARK: - Sync Handle
    var syncPublisher: AnyPublisher<[BaseDocumentUpdate], Never> {
        return syncSubject
            .merge(with: Just(isOpened ? [.general] : []))
            .filter { $0.isNotEmpty }
            .eraseToAnyPublisher()
    }
    private var syncSubject = PassthroughSubject<[BaseDocumentUpdate], Never>()
        
    init(
        objectId: String,
        spaceId: String,
        mode: DocumentMode,
        objectLifecycleService: some ObjectLifecycleServiceProtocol,
        propertyDetailsStorage: some PropertyDetailsStorageProtocol,
        objectTypeProvider: some ObjectTypeProviderProtocol,
        accountParticipantsStorage: some AccountParticipantsStorageProtocol,
        eventsListener: some EventsListenerProtocol,
        viewModelSetter: some DocumentViewModelSetterProtocol,
        infoContainer: some InfoContainerProtocol,
        restrictionsContainer: ObjectRestrictionsContainer,
        detailsStorage: ObjectDetailsStorage
    ) {
        self.objectId = objectId
        self.spaceId = spaceId
        self.mode = mode
        self.eventsListener = eventsListener
        self.viewModelSetter = viewModelSetter
        self.objectLifecycleService = objectLifecycleService
        self.propertyDetailsStorage = propertyDetailsStorage
        self.objectTypeProvider = objectTypeProvider
        self.accountParticipantsStorage = accountParticipantsStorage
        self.infoContainer = infoContainer
        self.restrictionsContainer = restrictionsContainer
        self.detailsStorage = detailsStorage
        
        setup()
    }
    
    deinit {
        guard mode.isHandling, isOpened, basicUserInfoStorage.usersId.isNotEmpty else { return }
        Task.detached(priority: .userInitiated) { [objectLifecycleService, objectId, spaceId] in
            try await objectLifecycleService.close(contextId: objectId, spaceId: spaceId)
        }
    }
    
    // MARK: - BaseDocumentProtocol
    
    @MainActor
    func open() async throws {
        switch mode {
        case .handling:
            guard !isOpened else { return }
            if openTask.isNil {
                openTask = Task { [weak self, objectId, spaceId, objectLifecycleService] in
                    let model = try await objectLifecycleService.open(contextId: objectId, spaceId: spaceId)
                    self?.setupView(model)
                }
            }
            try await openTask?.value
        case .preview:
            if openTask.isNil {
                openTask = Task { [weak self] in
                    try await self?.updateDocumentPreview()
                }
            }
            try await openTask?.value
        case .version(let versionId):
            if openTask.isNil {
                openTask = Task { [weak self] in
                    try await self?.updateDocumentVersion(versionId)
                }
            }
            try await openTask?.value
        }
    }
    
    @MainActor
    func update() async throws {
        switch mode {
        case .handling:
            anytypeAssertionFailure("Document was created in `handling` mode. You can't update it")
        case .preview:
            try await updateDocumentPreview()
        case .version(let versionId):
            try await updateDocumentVersion(versionId)
        }
    }
    
    @MainActor
    func close() async throws {
        guard mode.isHandling, isOpened, basicUserInfoStorage.usersId.isNotEmpty else { return }
        try await objectLifecycleService.close(contextId: objectId, spaceId: spaceId)
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
    
    @MainActor
    private func updateDocumentPreview() async throws {
        let model = try await objectLifecycleService.openForPreview(contextId: objectId, spaceId: spaceId)
        setupView(model)
    }
    
    @MainActor
    private func updateDocumentVersion(_ versionId: String) async throws {
        let model = try await historyVersionsService.showVersion(objectId: objectId, versionId: versionId)
        setupView(model)
    }
    
    private func setup() {
        eventsListener.setOnUpdateReceice({ [weak self] updates in
            DispatchQueue.main.async { [weak self] in
                self?.triggerSync(updates: updates)
            }
        })
        if mode.isHandling {
            eventsListener.startListening()
        }
    }
    
    private func makeChildren() -> [BlockInformation] {
        guard let model = infoContainer.get(id: objectId) else {
            return children
        }
        return model.flatChildrenTree(container: infoContainer)
    }
    
    private func triggerSync(updates: [DocumentUpdate]) {
        
        // Notify only when document is set to prevent invalid initial state
        guard isOpened else { return }
        
        var docUpdates = updates.flatMap { update -> [BaseDocumentUpdate] in
            switch update {
            case .general, .relationDetails:
                return [.general]
            case .block(let blockId):
                return [.block(blockId: blockId)]
            case .details(let id):
                return [.details(id: id)]
            case .unhandled(let blockId):
                return [.unhandled(blockId: blockId)]
            case .syncStatus:
                return [.syncStatus]
            case .restrictions, .close:
                return [] // A lot of casese for update relations
            }
        }
        
        let permissioUpdates = triggerUpdatePermissions(updates: updates)
        docUpdates.append(contentsOf: permissioUpdates)
        
        let relationUpdates = triggerUpdateRelations(updates: updates, permissionsChanged: permissioUpdates.isNotEmpty)
        docUpdates.append(contentsOf: relationUpdates)
        
        if updates.contains(where: { $0 == .general || $0.isBlock }) {
            let newChildren = makeChildren()
            if newChildren != children {
                children = newChildren
                docUpdates.append(.children)
            }
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
        // Start subscription before document is marked as opened
        setupSubscriptions()
        isOpened = true
        triggerSync(updates: [.general])
    }

    @MainActor
    private func setupSubscriptions() {
        syncStatusStorage.statusPublisher(spaceId: spaceId).sink { [weak self] info in
            self?.syncStatus = info.status
            self?.triggerSync(updates: [.syncStatus])
        }.store(in: &subscriptions)
        
        accountParticipantsStorage.canEditPublisher(spaceId: spaceId).receiveOnMain().sink { [weak self] canEdit in
            self?.participantIsEditor = canEdit
            self?.triggerSync(updates: [.restrictions])
        }
        .store(in: &subscriptions)
        
        propertyDetailsStorage.relationsDetailsPublisher(spaceId: spaceId)
            .sink { [weak self] details in
                guard let self, let objectDetails = self.details else { return }
                
                let contains = details.contains { objectDetails.values.map(\.key).contains([$0.key]) }
                if contains {
                    triggerSync(updates: [.relationDetails])
                }
            }
            .store(in: &subscriptions)
    }
    
    private func triggerUpdateRelations(updates: [DocumentUpdate], permissionsChanged: Bool) -> [BaseDocumentUpdate] {
        guard let details else { return [] }
        
        var updatesForRelations: [DocumentUpdate] = [.general, .details(id: objectId)]
        updatesForRelations.append(contentsOf: parsedRelationDependedDetailsEvents)
        updatesForRelations.append(.details(id: details.type))
        
        guard updates.contains(where: { updatesForRelations.contains($0) }) || permissionsChanged else { return [] }

        guard let newRelations = buildRelations(details: details) else { return [] }
        
        let dependedObjectIds = newRelations.all.flatMap(\.dependedObjects)
        parsedRelationDependedDetailsEvents = dependedObjectIds.map { .details(id: $0) }
        if parsedRelations != newRelations {
            parsedRelations = newRelations
            return [.relations]
        }
        
        return []
    }
    
    private func buildRelations(details: ObjectDetails) -> ParsedRelations? {
        if details.isTemplate {
            return buildRelationsForTemplate(details: details)
        } else {
            return buildRelationsForObject(details: details)
        }
    }
    
    private func buildRelationsForTemplate(details: ObjectDetails) -> ParsedRelations? {
        guard let targetObjectType = try? objectTypeProvider.objectType(id: details.targetObjectType) else {
            return nil
        }
        
        let objectRelations = propertyDetailsStorage.relationsDetails(
            keys:  details.values.map(\.key), spaceId: spaceId
        )
        
        let objectFeaturedRelations = propertyDetailsStorage.relationsDetails(
            ids:  details.featuredRelations, spaceId: spaceId
        )

        let recommendedRelations = propertyDetailsStorage.relationsDetails(
            ids: targetObjectType.recommendedRelations, spaceId: spaceId
        )
        
        let recommendedFeaturedRelations = propertyDetailsStorage.relationsDetails(
            ids: targetObjectType.recommendedFeaturedRelations, spaceId: spaceId
        )
        
        let recommendedHiddenRelations = propertyDetailsStorage.relationsDetails(
            ids: targetObjectType.recommendedHiddenRelations, spaceId: spaceId
        )
        
        return relationBuilder.parsedRelations(
            objectRelations: objectRelations,
            objectFeaturedRelations: objectFeaturedRelations,
            recommendedRelations: recommendedRelations,
            recommendedFeaturedRelations: recommendedFeaturedRelations,
            recommendedHiddenRelations: recommendedHiddenRelations,
            objectId: objectId,
            relationValuesIsLocked: !permissions.canEditRelationValues,
            storage: detailsStorage
        )
    }
    
    private func buildRelationsForObject(details: ObjectDetails) -> ParsedRelations {
        let objectRelations = propertyDetailsStorage.relationsDetails(
            keys:  details.values.map(\.key), spaceId: spaceId
        )
        
        let objectFeaturedRelations = propertyDetailsStorage.relationsDetails(
            keys: details.featuredRelations, spaceId: spaceId
        )

        let recommendedRelations = propertyDetailsStorage.relationsDetails(
            ids: details.objectType.recommendedRelations, spaceId: spaceId
        )
        
        let recommendedFeaturedRelations = propertyDetailsStorage.relationsDetails(
            ids: details.objectType.recommendedFeaturedRelations, spaceId: spaceId
        )
        
        let recommendedHiddenRelations = propertyDetailsStorage.relationsDetails(
            ids: details.objectType.recommendedHiddenRelations, spaceId: spaceId
        )
        
        return relationBuilder.parsedRelations(
            objectRelations: objectRelations,
            objectFeaturedRelations: objectFeaturedRelations,
            recommendedRelations: recommendedRelations,
            recommendedFeaturedRelations: recommendedFeaturedRelations,
            recommendedHiddenRelations: recommendedHiddenRelations,
            objectId: objectId,
            relationValuesIsLocked: !permissions.canEditRelationValues,
            storage: detailsStorage
        )
    }
    
    private func triggerUpdatePermissions(updates: [DocumentUpdate]) -> [BaseDocumentUpdate] {
        let updatesForPermissions: [DocumentUpdate] = [.general, .details(id: objectId), .block(blockId: objectId), .restrictions]
        guard updates.contains(where: { updatesForPermissions.contains($0) }) else { return [] }
        
        let newPermissios = ObjectPermissions(
            details: details ?? ObjectDetails(id: ""),
            isLocked: isLocked,
            participantCanEdit: participantIsEditor, 
            isVersionMode: mode.isVersion,
            objectRestrictions: objectRestrictions.objectRestriction
        )
        
        if permissions != newPermissios {
            permissions = newPermissios
            return [.permissions]
        }
        
        return []
    }
}
