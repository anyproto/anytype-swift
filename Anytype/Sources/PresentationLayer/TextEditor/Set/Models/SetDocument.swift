import Foundation
import Services
import Combine
import AnytypeCore

final class SetDocument: SetDocumentProtocol, @unchecked Sendable {
    
    let document: any BaseDocumentProtocol
    
    var objectId: String { document.objectId }
    var blockId: String { inlineParameters?.blockId ?? SetConstants.dataviewBlockId }
    var targetObjectId: String { inlineParameters?.targetObjectID ?? objectId }
    var spaceId: String { document.spaceId }
    
    var details: ObjectDetails? {
        if let targetObjectID = inlineParameters?.targetObjectID {
            return document.detailsStorage.get(id: targetObjectID)
        } else {
            return document.details
        }
    }
    
    var detailsPublisher: AnyPublisher<ObjectDetails, Never> {
        document.detailsPublisher
    }
    
    var mode: DocumentMode { document.mode }
    
    var blockDataview: BlockDataview? {
        let blockId = inlineParameters?.blockId ?? SetConstants.dataviewBlockId
        guard let blockInfo = document.infoContainer.get(id: blockId) else {
            return nil
        }
        if case .dataView(let data) = blockInfo.content {
           return data
        } else {
            return nil
        }
    }
    
    var dataViewRelationsDetails: [PropertyDetails] = []
    
    var analyticsType: AnalyticsObjectType {
        details?.analyticsType ?? .object(typeId: "")
    }
    
    var featuredRelationsForEditor: [Property] {
        document.featuredRelationsForEditor
    }
    
    var parsedProperties: ParsedProperties {
        document.parsedProperties
    }
    
    var permissions: ObjectPermissions {
        document.permissions
    }
    
    private(set) var setPermissions = SetPermissions()
    
    var setUpdatePublisher: AnyPublisher<SetDocumentUpdate, Never> { updateSubject.eraseToAnyPublisher() }
    private let updateSubject = PassthroughSubject<SetDocumentUpdate, Never>()
    
    @Published var dataView = BlockDataview.empty
    var dataviewPublisher: AnyPublisher<BlockDataview, Never> { $dataView.eraseToAnyPublisher() }
    
    @Published var activeView = DataviewView.empty
    var activeViewPublisher: AnyPublisher<DataviewView, Never> { $activeView.eraseToAnyPublisher() }
    
    @Published var activeViewSorts: [SetSort] = []
    @Published var activeViewFilters: [SetFilter] = []
    
    let inlineParameters: EditorInlineSetObject?
    
    private var participantIsEditor = false
    private var subscriptions = [AnyCancellable]()
    private let propertyDetailsStorage: any PropertyDetailsStorageProtocol
    private let objectTypeProvider: any ObjectTypeProviderProtocol
    private let accountParticipantsStorage: any ParticipantsStorageProtocol
    private let permissionsBuilder: any SetPermissionsBuilderProtocol
    @Injected(\.setContentViewDataBuilder)
    var dataBuilder: any SetContentViewDataBuilderProtocol
    
    init(
        document: some BaseDocumentProtocol,
        inlineParameters: EditorInlineSetObject?,
        propertyDetailsStorage: some PropertyDetailsStorageProtocol,
        objectTypeProvider: some ObjectTypeProviderProtocol,
        accountParticipantsStorage: some ParticipantsStorageProtocol,
        permissionsBuilder: some SetPermissionsBuilderProtocol
    ) {
        self.document = document
        self.inlineParameters = inlineParameters
        self.propertyDetailsStorage = propertyDetailsStorage
        self.objectTypeProvider = objectTypeProvider
        self.accountParticipantsStorage = accountParticipantsStorage
        self.permissionsBuilder = permissionsBuilder
    }
    
    func view(by id: String) -> DataviewView {
        dataView.views.first { $0.id == id } ?? .empty
    }
    
    func sortedRelations(for viewId: String) -> [SetProperty] {
        let view = view(by: viewId)
        return dataBuilder.sortedRelations(dataview: dataView, view: view, spaceId: spaceId)
    }
    
    func sorts(for viewId: String) -> [SetSort] {
        let view = view(by: viewId)
        return view.sorts.compactMap { sort in
            let relationDetails = dataViewRelationsDetails.first { relationDetails in
                sort.relationKey == relationDetails.key
            }
            guard let relationDetails = relationDetails else { return nil }
            
            return SetSort(relationDetails: relationDetails, sort: sort)
        }
    }
    
    func filters(for viewId: String) -> [SetFilter] {
        let view = view(by: viewId)
        return view.filters.compactMap { filter in
            let relationDetails = dataViewRelationsDetails.first { relationDetails in
                filter.relationKey == relationDetails.key
            }
            guard let relationDetails = relationDetails else { return nil }
            
            return SetFilter(relationDetails: relationDetails, filter: filter)
        }
    }
    
    func canStartSubscription() -> Bool {
        (details?.filteredSetOf.isNotEmpty ?? false) || isCollection()
    }
    
    func viewRelations(viewId: String, excludeRelations: [PropertyDetails]) -> [PropertyDetails] {
        let view = view(by: viewId)
        return dataBuilder.activeViewRelations(
            dataViewRelationsDetails: dataViewRelationsDetails,
            view: view,
            excludeRelations: excludeRelations,
            spaceId: spaceId
        )
    }
    
    func objectOrderIds(for groupId: String) -> [String] {
        dataView.objectOrders.first { [weak self] objectOrder in
            let sameGroup = objectOrder.groupID.isEmpty || objectOrder.groupID == groupId
            return objectOrder.viewID == self?.activeView.id && sameGroup
        }?.objectIds ?? []
    }
    
    func updateActiveViewIdAndReload(_ id: String) {
        updateDataview(with: id)
        updateData()
    }
    
    func isTypeSet() -> Bool {
        !isCollection() && !isSetByRelation()
    }
    
    func isBookmarksSet() -> Bool {
        guard let details,
              let bookmarkType = (try? objectTypeProvider.objectType(recommendedLayout: .bookmark, spaceId: document.spaceId)) else { return false }
        return details.filteredSetOf.contains(bookmarkType.id)
    }
    
    func isSetByRelation() -> Bool {
        let relation = parsedProperties.systemProperties.first { $0.key == BundledPropertyKey.setOf.rawValue }
        if let relation, relation.hasSelectedObjectsRelationType {
            return true
        } else {
            return false
        }
    }
    
    func isCollection() -> Bool {
        details?.isCollection ?? false
    }
    
    func isActiveHeader() -> Bool {
        guard let details else {
            anytypeAssertionFailure("SetDocument: No details in isHeaderActive")
            return false
        }
        return details.isCollection || isSetByRelation() || details.filteredSetOf.isNotEmpty
    }
    
    func defaultObjectTypeForActiveView() throws -> ObjectType {
        return try defaultObjectTypeForView(activeView)
    }
    
    func defaultObjectTypeForView(_ view: DataviewView) throws -> ObjectType {
        if let viewDefaulTypeId = view.defaultObjectTypeID, viewDefaulTypeId.isNotEmpty {
            return try objectTypeProvider.objectType(id: viewDefaulTypeId)
        }
        return try objectTypeProvider.objectType(uniqueKey: .page, spaceId: spaceId)
    }
    
    @MainActor
    func open() async throws {
        try await document.open()
        setup()
    }
    
    @MainActor
    func update() async throws {
        try await document.update()
        setup()
    }
    
    @MainActor
    func close() async throws {
        try await document.close()
    }
    
    @Published private var sync: Void?
    var syncPublisher: AnyPublisher<Void, Never> {
        $sync.compactMap { $0 }.eraseToAnyPublisher()
    }
    
    // MARK: - Private
    
    private func setup() {
        guard subscriptions.isEmpty else { return }
        document.syncPublisher.receiveOnMain().sink { [weak self] update in
            self?.updateData()
        }
        .store(in: &subscriptions)
        
        document.syncStatusDataPublisher.sink { [weak self] status in
            self?.updateSubject.send(.syncStatus(status))
        }
        .store(in: &subscriptions)
        
        propertyDetailsStorage.relationsDetailsPublisher(spaceId: document.spaceId).sink { [weak self] _ in
            self?.updateDataViewRelations()
            self?.triggerSync()
        }
        .store(in: &subscriptions)
        
        Task.detached { [weak self, accountParticipantsStorage, spaceId] in
            for await canEdit in accountParticipantsStorage.canEditSequence(spaceId: spaceId) {
                await Task { @MainActor [weak self] in
                    self?.participantIsEditor = canEdit
                    self?.updateData()
                }.value
            }
        }
        .cancellable()
        .store(in: &subscriptions)
    }
    
    private func updateData() {
        dataView = blockDataview ?? .empty
        updateDataViewRelations()
        
        let prevActiveView = activeView
        
        updateActiveViewIdIfNeeded()
        activeView = dataView.views.first { $0.id == dataView.activeViewId } ?? .empty
        
        updateSorts()
        updateFilters()
        
        let shouldClearState = shouldClearState(prevActiveView: prevActiveView)
        updateSubject.send(.dataviewUpdated(clearState: shouldClearState))
        setPermissions = permissionsBuilder.build(setDocument: self, participantCanEdit: participantIsEditor)
        
        triggerSync()
    }
    
    private func updateDataViewRelations() {
        let relationsDetails = propertyDetailsStorage.relationsDetails(keys: dataView.relationLinks.map(\.key), spaceId: spaceId, includeDeleted: false)
        dataViewRelationsDetails = enrichedByDoneRelationIfNeeded(relationsDetails: relationsDetails)
    }
    
    private func enrichedByDoneRelationIfNeeded(relationsDetails: [PropertyDetails]) -> [PropertyDetails] {
        // force insert Done relation for dataView if needed
        let containsDoneRelation = relationsDetails.first { $0.key == BundledPropertyKey.done.rawValue }.isNotNil
        let donePropertyDetails = try? propertyDetailsStorage.relationsDetails(bundledKey: BundledPropertyKey.done, spaceId: spaceId)
        if !containsDoneRelation, let donePropertyDetails {
            var relationsDetails = relationsDetails
            relationsDetails.append(donePropertyDetails)
            return relationsDetails
        } else {
            return relationsDetails
        }
    }
    
    private func updateSorts() {
        activeViewSorts = sorts(for: activeView.id)
    }
    
    private func updateFilters() {
        activeViewFilters = filters(for: activeView.id)
    }
    
    private func shouldClearState(prevActiveView: DataviewView) -> Bool {
        let modeChanged = (prevActiveView.type.hasGroups && !activeView.type.hasGroups) ||
        (!prevActiveView.type.hasGroups && activeView.type.hasGroups)
        
        let groupRelationKeyChanged = prevActiveView.groupRelationKey != activeView.groupRelationKey
        
        return modeChanged || groupRelationKeyChanged
    }
    
    private func updateActiveViewIdIfNeeded() {
        let firstViewId = dataView.views.first?.id
        let currentActiveViewId = dataView.activeViewId
        
        guard let firstViewId else {
            updateActiveViewId(with: "")
            return
        }
        
        if currentActiveViewId.isEmpty || dataView.views.first(where: { $0.id == currentActiveViewId }).isNil {
            updateActiveViewId(with: firstViewId)
        }
    }
    
    private func updateActiveViewId(with viewId: String) {
        updateDataview(with: viewId)
        dataView.activeViewId = viewId
    }
    
    private func updateDataview(with activeViewId: String) {
        document.infoContainer.updateDataview(blockId: blockId) { dataView in
            dataView.updated(activeViewId: activeViewId)
        }
    }
    
    private func triggerSync() {
        sync = ()
    }
}
