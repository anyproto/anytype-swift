import Foundation
import Services
import Combine
import AnytypeCore

class SetDocument: SetDocumentProtocol {
    let document: BaseDocumentProtocol
    
    var objectId: Services.BlockId { document.objectId }
    var blockId: BlockId { inlineParameters?.blockId ?? SetConstants.dataviewBlockId }
    var targetObjectId: BlockId { inlineParameters?.targetObjectID ?? objectId }
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
    
    var updatePublisher: AnyPublisher<DocumentUpdate, Never> {
        document.updatePublisher
    }
    
    var forPreview: Bool { document.forPreview }
    
    var dataviews: [BlockDataview] {
        return document.children.compactMap { info -> BlockDataview? in
            if case .dataView(let data) = info.content {
                if let blockId = inlineParameters?.blockId {
                    return info.id == blockId ? data : nil
                } else {
                    return data
                }
            }
            return nil
        }
    }
    
    var dataViewRelationsDetails: [RelationDetails] = []
    
    var viewRelationValueIsLocked: Bool {
        activeView.type == .gallery ||
        activeView.type == .list ||
        (FeatureFlags.setKanbanView && activeView.type == .kanban)
    }
    
    var relationValuesIsLocked: Bool {
        return document.relationValuesIsLocked
    }
    
    var analyticsType: AnalyticsObjectType {
        details?.analyticsType ?? .object(typeId: "")
    }
    
    var featuredRelationsForEditor: [Relation] {
        document.featuredRelationsForEditor
    }
    
    var parsedRelations: ParsedRelations {
        document.parsedRelations
    }
    
    var objectRestrictions: ObjectRestrictions {
        document.objectRestrictions
    }
    
    var setUpdatePublisher: AnyPublisher<SetDocumentUpdate, Never> { updateSubject.eraseToAnyPublisher() }
    private let updateSubject = PassthroughSubject<SetDocumentUpdate, Never>()
    
    @Published var dataView = BlockDataview.empty
    var dataviewPublisher: AnyPublisher<BlockDataview, Never> { $dataView.eraseToAnyPublisher() }
    
    @Published var activeView = DataviewView.empty
    var activeViewPublisher: AnyPublisher<DataviewView, Never> { $activeView.eraseToAnyPublisher() }
    
    @Published var activeViewSorts: [SetSort] = []
    @Published var activeViewFilters: [SetFilter] = []
    
    let inlineParameters: EditorInlineSetObject?
    
    private var subscriptions = [AnyCancellable]()
    private let relationDetailsStorage: RelationDetailsStorageProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    let dataBuilder: SetContentViewDataBuilder
    
    init(
        document: BaseDocumentProtocol,
        inlineParameters: EditorInlineSetObject?,
        relationDetailsStorage: RelationDetailsStorageProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol
    ) {
        self.document = document
        self.inlineParameters = inlineParameters
        self.relationDetailsStorage = relationDetailsStorage
        self.dataBuilder = SetContentViewDataBuilder(
            relationsBuilder: RelationsBuilder(),
            detailsStorage: document.detailsStorage,
            relationDetailsStorage: relationDetailsStorage
        )
        self.objectTypeProvider = objectTypeProvider
        self.setup()
    }
    
    func view(by id: String) -> DataviewView {
        dataView.views.first { $0.id == id } ?? .empty
    }
    
    func sortedRelations(for viewId: String) -> [SetRelation] {
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
        (details?.setOf.isNotEmpty ?? false) || isCollection()
    }
    
    func viewRelations(viewId: String, excludeRelations: [RelationDetails]) -> [RelationDetails] {
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
            objectOrder.viewID == self?.activeView.id && objectOrder.groupID == groupId
        }?.objectIds ?? []
    }
    
    func updateActiveViewId(_ id: BlockId) {
        updateDataview(with: id)
        updateData()
    }
    
    func isTypeSet() -> Bool {
        !isCollection() && !isSetByRelation()
    }
    
    func isBookmarksSet() -> Bool {
        guard let details,
              let bookmarkType = (try? objectTypeProvider.objectType(recommendedLayout: .bookmark, spaceId: document.spaceId)) else { return false }
        return details.setOf.contains(bookmarkType.id)
    }
    
    func isSetByRelation() -> Bool {
        let relation = parsedRelations.installed.first { $0.key == BundledRelationKey.setOf.rawValue }
        if let relation, relation.hasSelectedObjectsRelationType {
            return true
        } else {
            return false
        }
    }
    
    func isCollection() -> Bool {
        details?.isCollection ?? false
    }
    
    func canCreateObject() -> Bool {
        guard let details else {
            anytypeAssertionFailure("SetDocument: No details in canCreateObject")
            return false
        }
        guard details.isList else { return false }
        
        if details.isCollection { return true }
        if isSetByRelation() { return true }
        
        // Set query validation
        // Create objects in sets by type only permitted if type is Page-like
        guard let setOfId = details.setOf.first(where: { $0.isNotEmpty }) else {
            return false
        }
        
        guard let layout = try? ObjectTypeProvider.shared.objectType(id: setOfId).recommendedLayout else {
            return false
        }
        
        return DetailsLayout.supportedForCreationInSets.contains(layout)
    }
    
    func isActiveHeader() -> Bool {
        guard let details else {
            anytypeAssertionFailure("SetDocument: No details in isHeaderActive")
            return false
        }
        return details.isCollection || isSetByRelation() || details.setOf.first(where: { $0.isNotEmpty }).isNotNil
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
    }
    
    @MainActor
    func openForPreview() async throws {
        try await document.openForPreview()
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
        document.updatePublisher.sink { [weak self] update in
            self?.onDocumentUpdate(update)
        }
        .store(in: &subscriptions)
        
        relationDetailsStorage.relationsDetailsPublisher.sink { [weak self] _ in
            self?.updateDataViewRelations()
            self?.triggerSync()
        }
        .store(in: &subscriptions)
    }
    
    private func onDocumentUpdate(_ data: DocumentUpdate) {
        switch data {
        case .general, .blocks, .details, .dataSourceUpdate:
            updateData()
        case .syncStatus(let status):
            updateSubject.send(.syncStatus(status))
        }
    }
    
    private func updateData() {
        dataView = dataviews.first ?? .empty
        updateDataViewRelations()
        
        let prevActiveView = activeView
        
        updateActiveViewId()
        activeView = dataView.views.first { $0.id == dataView.activeViewId } ?? .empty
        
        updateSorts()
        updateFilters()
        
        let shouldClearState = shouldClearState(prevActiveView: prevActiveView)
        updateSubject.send(.dataviewUpdated(clearState: shouldClearState))
        triggerSync()
    }
    
    private func updateDataViewRelations() {
        dataViewRelationsDetails = relationDetailsStorage.relationsDetails(for: dataView.relationLinks, spaceId: spaceId, includeDeleted: false)
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
    
    private func updateActiveViewId() {
        let activeViewId = dataView.views.first?.id
        if let activeViewId = activeViewId {
            if self.dataView.activeViewId.isEmpty || !dataView.views.contains(where: { $0.id == self.dataView.activeViewId }) {
                updateDataview(with: activeViewId)
                dataView.activeViewId = activeViewId
            }
        } else {
            updateDataview(with: "")
            dataView.activeViewId = ""
        }
    }
    
    private func updateDataview(with activeViewId: BlockId) {
        document.infoContainer.updateDataview(blockId: blockId) { dataView in
            dataView.updated(activeViewId: activeViewId)
        }
    }
    
    private func triggerSync() {
        sync = ()
    }
}
