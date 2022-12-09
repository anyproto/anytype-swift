import Foundation
import BlocksModels
import Combine
import AnytypeCore

class SetDocument: SetDocumentProtocol {
    let document: BaseDocumentProtocol
    
    var objectId: BlocksModels.BlockId {
        document.objectId
    }
    
    var details: ObjectDetails? {
        document.details
    }
    
    var dataviews: [BlockDataview] {
        return document.children.compactMap { info -> BlockDataview? in
            if case .dataView(let data) = info.content {
                return data
            }
            return nil
        }
    }
    
    var dataViewRelationsDetails: [RelationDetails] = []
    
    var sortedRelations: [SetRelation] {
        dataBuilder.sortedRelations(dataview: dataView, view: activeView)
    }
    
    var isObjectLocked: Bool {
        document.isLocked ||
        activeView.type == .gallery ||
        (FeatureFlags.setListView && activeView.type == .list)
    }
    
    var featuredRelationsForEditor: [Relation] {
        document.featuredRelationsForEditor
    }
    
    var updatePublisher: AnyPublisher<SetDocumentUpdate, Never> { updateSubject.eraseToAnyPublisher() }
    private let updateSubject = PassthroughSubject<SetDocumentUpdate, Never>()
    
    @Published var dataView = BlockDataview.empty
    var dataviewPublisher: AnyPublisher<BlockDataview, Never> { $dataView.eraseToAnyPublisher() }
    
    @Published var activeView = DataviewView.empty
    var activeViewPublisher: AnyPublisher<DataviewView, Never> { $activeView.eraseToAnyPublisher() }
    
    @Published var sorts: [SetSort] = []
    var sortsPublisher: AnyPublisher<[SetSort], Never> { $sorts.eraseToAnyPublisher() }
    
    @Published var filters: [SetFilter] = []
    var filtersPublisher: AnyPublisher<[SetFilter], Never> { $filters.eraseToAnyPublisher() }
    
    
    private var subscriptions = [AnyCancellable]()
    private let relationDetailsStorage: RelationDetailsStorageProtocol
    private let dataBuilder = SetContentViewDataBuilder()
    
    init(document: BaseDocumentProtocol, relationDetailsStorage: RelationDetailsStorageProtocol) {
        self.document = document
        self.relationDetailsStorage = relationDetailsStorage
        self.setup()
    }
    
    func activeViewRelations(excludeRelations: [RelationDetails]) -> [RelationDetails] {
        dataBuilder.activeViewRelations(
            dataViewRelationsDetails: dataViewRelationsDetails,
            view: activeView,
            excludeRelations: excludeRelations
        )
    }
    
    func updateActiveViewId(_ id: BlockId) {
        updateDataview(with: id)
        updateData()
    }
    
    func isBookmarksSet() -> Bool {
        dataView.source.contains(ObjectTypeId.BundledTypeId.bookmark.rawValue)
    }
    
    func isRelationsSet() -> Bool {
        let relation = document.parsedRelations.all.first { $0.key == BundledRelationKey.setOf.rawValue }
        if let relation, relation.hasSelectedObjectsRelationType {
            return true
        } else {
            return false
        }
    }
    
    @MainActor
    func open() async throws {
        try await document.open()
        updateData()
    }
    
    // MARK: - Private
    
    private func setup() {
        document.updatePublisher.sink { [weak self] update in
            DispatchQueue.main.async {
                self?.onDocumentUpdate(update)
            }
        }
        .store(in: &subscriptions)
    }
    
    private func onDocumentUpdate(_ data: DocumentUpdate) {
        switch data {
        case .general, .blocks, .details, .dataSourceUpdate:
            updateData()
        case .syncStatus(let status):
            updateSubject.send(.syncStatus(status))
        case .header:
            break
        }
    }
    
    private func updateData() {
        dataView = dataviews.first ?? .empty
        
        let prevActiveView = activeView
        activeView = dataView.views.first { $0.id == dataView.activeViewId } ?? .empty
        
        updateDataViewRelations()
        updateActiveViewId()
        updateSorts()
        updateFilters()
        
        let shouldClearState = shouldClearState(prevActiveView: prevActiveView)
        updateSubject.send(.dataviewUpdated(clearState: shouldClearState))
    }
    
    private func updateDataViewRelations() {
        dataViewRelationsDetails = relationDetailsStorage.relationsDetails(for: dataView.relationLinks)
    }
    
    private func updateSorts() {
        sorts = activeView.sorts.uniqued().compactMap { sort in
            let relationDetails = dataViewRelationsDetails.first { relationDetails in
                sort.relationKey == relationDetails.key
            }
            guard let relationDetails = relationDetails else { return nil }
            
            return SetSort(relationDetails: relationDetails, sort: sort)
        }
    }
    
    private func updateFilters() {
        filters = activeView.filters.compactMap { filter in
            let relationDetails = dataViewRelationsDetails.first { relationDetails in
                filter.relationKey == relationDetails.key
            }
            guard let relationDetails = relationDetails else { return nil }
            
            return SetFilter(relationDetails: relationDetails, filter: filter)
        }
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
        document.infoContainer.updateDataview(blockId: SetConstants.dataviewBlockId) { dataView in
            dataView.updated(activeViewId: activeViewId)
        }
    }
}
