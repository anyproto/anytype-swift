import Foundation
import Services
import Combine
import AnytypeCore

class SetDocument: SetDocumentProtocol {
    let document: BaseDocumentProtocol
    
    var objectId: Services.BlockId {
        document.objectId
    }
    
    var targetObjectID: String?
    
    var details: ObjectDetails? {
        if let targetObjectID {
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
    
    var dataviews: [BlockDataview] {
        return document.children.compactMap { info -> BlockDataview? in
            if case .dataView(let data) = info.content {
                if let blockId {
                    return info.id == blockId ? data : nil
                } else {
                    return data
                }
            }
            return nil
        }
    }
    
    var dataViewRelationsDetails: [RelationDetails] = []
    
    var isObjectLocked: Bool {
        document.isLocked ||
        activeView.type == .gallery ||
        activeView.type == .list ||
        (FeatureFlags.setKanbanView && activeView.type == .kanban)
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
    
    var setUpdatePublisher: AnyPublisher<SetDocumentUpdate, Never> { updateSubject.eraseToAnyPublisher() }
    private let updateSubject = PassthroughSubject<SetDocumentUpdate, Never>()
    
    @Published var dataView = BlockDataview.empty
    var dataviewPublisher: AnyPublisher<BlockDataview, Never> { $dataView.eraseToAnyPublisher() }
    
    @Published var activeView = DataviewView.empty
    var activeViewPublisher: AnyPublisher<DataviewView, Never> { $activeView.eraseToAnyPublisher() }
    
    @Published var activeViewSorts: [SetSort] = []
    @Published var activeViewFilters: [SetFilter] = []
    
    let blockId: BlockId?
    
    private var subscriptions = [AnyCancellable]()
    private let relationDetailsStorage: RelationDetailsStorageProtocol
    let dataBuilder: SetContentViewDataBuilder
    
    init(
        document: BaseDocumentProtocol,
        blockId: BlockId?,
        targetObjectID: String?,
        relationDetailsStorage: RelationDetailsStorageProtocol)
    {
        self.document = document
        self.relationDetailsStorage = relationDetailsStorage
        self.targetObjectID = targetObjectID
        self.blockId = blockId
        self.dataBuilder = SetContentViewDataBuilder(
            relationsBuilder: RelationsBuilder(),
            detailsStorage: document.detailsStorage,
            relationDetailsStorage: relationDetailsStorage
        )
        self.setup()
    }
    
    func view(by id: String) -> DataviewView {
        dataView.views.first { $0.id == id } ?? .empty
    }
    
    func sortedRelations(for viewId: String) -> [SetRelation] {
        let view = view(by: viewId)
        return dataBuilder.sortedRelations(dataview: dataView, view: view)
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
            excludeRelations: excludeRelations
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
        !isCollection() && !isRelationsSet()
    }
    
    func isBookmarksSet() -> Bool {
        details?.setOf.contains(ObjectTypeId.BundledTypeId.bookmark.rawValue) ?? false
    }
    
    func isRelationsSet() -> Bool {
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
        sync = ()
    }
    
    private func updateDataViewRelations() {
        dataViewRelationsDetails = relationDetailsStorage.relationsDetails(for: dataView.relationLinks, includeDeleted: false)
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
        let activeViewId = dataView.views.first(where: { $0.type.isSupported })?.id ?? dataView.views.first?.id
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
        document.infoContainer.updateDataview(blockId: blockId ?? SetConstants.dataviewBlockId) { dataView in
            dataView.updated(activeViewId: activeViewId)
        }
    }
}
