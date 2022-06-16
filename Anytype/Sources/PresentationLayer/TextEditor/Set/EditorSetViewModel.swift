import Combine
import BlocksModels
import AnytypeCore
import ProtobufMessages
import SwiftUI

final class EditorSetViewModel: ObservableObject {
    @Published var dataView = BlockDataview.empty
    @Published private var records: [ObjectDetails] = []
    @Published private(set) var headerModel: ObjectHeaderViewModel!
    
    @Published var pagitationData = EditorSetPaginationData.empty
    
    var isEmpty: Bool {
        dataView.views.filter { $0.isSupported }.isEmpty
    }
    
    var activeView: DataviewView {
        dataView.views.first { $0.id == dataView.activeViewId } ?? .empty
    }
    
    var colums: [RelationMetadata] {
        sortedRelations.filter { $0.option.isVisible }.map(\.metadata)
    }
 
    var rows: [SetTableViewRowData] {
        dataBuilder.rowData(records, dataView: dataView, activeView: activeView, colums: colums, isObjectLocked: document.isLocked)
    }
    
    var sortedRelations: [SetRelation] {
        dataBuilder.sortedRelations(dataview: dataView, view: activeView)
    }
 
    var details: ObjectDetails? {
        document.details
    }
    
    var featuredRelations: [Relation] {
        document.featuredRelationsForEditor
    }
    
    var sorts: [SetSort] {
        activeView.sorts.uniqued().compactMap { sort in
            let metadata = dataView.relations.first { relation in
                sort.relationKey == relation.key
            }
            guard let metadata = metadata else { return nil }
            
            return SetSort(metadata: metadata, sort: sort)
        }
    }
    
    var relations: [RelationMetadata] {
        activeView.options.compactMap { option in
            let metadata = dataView.relations.first { relation in
                option.key == relation.key
            }
            
            guard let metadata = metadata,
                  shouldAddRelationMetadata(metadata) else { return nil }
            
            return metadata
        }
    }
    
    let document: BaseDocument
    private var router: EditorRouterProtocol!

    let paginationHelper = EditorSetPaginationHelper()
    private var subscription: AnyCancellable?
    private let subscriptionService = ServiceLocator.shared.subscriptionService()
    private let dataBuilder = SetTableViewDataBuilder()
    private let dataviewService: DataviewServiceProtocol
    private let searchService: SearchServiceProtocol
    
    init(
        document: BaseDocument,
        dataviewService: DataviewServiceProtocol,
        searchService: SearchServiceProtocol
    ) {
        ObjectTypeProvider.shared.resetCache()
        self.document = document
        self.dataviewService = dataviewService
        self.searchService = searchService
    }
    
    func setup(router: EditorRouterProtocol) {
        self.router = router
        self.headerModel = ObjectHeaderViewModel(document: document, router: router, isOpenedForPreview: false)
        
        subscription = document.updatePublisher.sink { [weak self] in
            self?.onDataChange($0)
        }
        
        document.open()
        setupDataview()
    }
    
    func onAppear() {
        guard document.isOpened else {
            router.goBack()
            return
        }
        setupSubscriptions()
        router?.setNavigationViewHidden(false, animated: true)
    }
    
    func onDisappear() {
        subscriptionService.stopAllSubscriptions()
    }
    
    func updateActiveViewId(_ id: BlockId) {
        document.infoContainer.updateDataview(blockId: SetConstants.dataviewBlockId) { dataView in
            dataView.updated(activeViewId: id)
        }
        
        setupDataview()
    }
    
    func setupSubscriptions() {
        subscriptionService.stopAllSubscriptions()
        guard !isEmpty else { return }
        
        subscriptionService.startSubscription(
            data: .set(
                .init(
                    dataView: dataView,
                    view: activeView,
                    currentPage: max(pagitationData.selectedPage, 1) // show first page for empty request
                )
            )
        ) { [weak self] subId, update in
            guard let self = self else { return }
            
            if case let .pageCount(count) = update {
                self.updatePageCount(count)
                return
            }
            
            self.records.applySubscriptionUpdate(update)
        }
    }
    
    // MARK: - Private
    
    private func onDataChange(_ data: DocumentUpdate) {
        switch data {
        case .general:
            objectWillChange.send()
            setupDataview()
        case .syncStatus, .blocks, .details, .dataSourceUpdate, .changeType:
            objectWillChange.send()
        case .header:
            break // handled in ObjectHeaderViewModel
        }
    }
    
    private func setupDataview() {
        anytypeAssert(document.dataviews.count < 2, "\(document.dataviews.count) dataviews in set", domain: .editorSet)
        document.dataviews.first.flatMap { dataView in
            anytypeAssert(dataView.views.isNotEmpty, "Empty views in dataview: \(dataView)", domain: .editorSet)
        }
        
        self.dataView = document.dataviews.first ?? .empty
        
        updateActiveViewId()
        setupSubscriptions()
    }
    
    private func updateActiveViewId() {
        if let activeViewId = dataView.views.first(where: { $0.isSupported })?.id {
            if self.dataView.activeViewId.isEmpty || !dataView.views.contains(where: { $0.id == self.dataView.activeViewId }) {
                self.dataView.activeViewId = activeViewId
            }
        } else {
            dataView.activeViewId = ""
        }
    }
    
    private func shouldAddRelationMetadata(_ relationMetadata: RelationMetadata) -> Bool {
        guard sorts.first(where: { $0.metadata.key == relationMetadata.key }) == nil else {
            return false
        }
        guard relationMetadata.key != ExceptionalSetSort.name.rawValue,
              relationMetadata.key != ExceptionalSetSort.done.rawValue else {
            return true
        }
        return !relationMetadata.isHidden &&
        relationMetadata.format != .file &&
        relationMetadata.format != .unrecognized
    }
    
    private func isFloatingSetMenuAvailable() -> Bool {
        FeatureFlags.isSetSortsAvailable ||
        FeatureFlags.isSetFiltersAvailable
    }
}

// MARK: - Routing
extension EditorSetViewModel {
    func showPage(_ data: EditorScreenData) {
        router.showPage(data: data)
    }
    
    func showRelationValueEditingView(key: String, source: RelationSource) {
        AnytypeAnalytics.instance().logChangeRelationValue(type: .set)

        router.showRelationValueEditingView(key: key, source: source)
    }
    
    func showRelationValueEditingView(
        objectId: BlockId,
        source: RelationSource,
        relation: Relation
    ) {
        AnytypeAnalytics.instance().logChangeRelationValue(type: .set)
        
        router.showRelationValueEditingView(
            objectId: objectId,
            source: source,
            relation: relation
        )
    }
    
    func showViewPicker() {
        let vc = UIHostingController(rootView: EditorSetViewPicker(setModel: self))
        router.presentSheet(vc)
    }
    
    func showSetSettings() {
        if isFloatingSetMenuAvailable() {
            router.presentFullscreen(
                AnytypePopup(
                    viewModel: EditorSetSettingsViewModel(setModel: self),
                    floatingPanelStyle: true,
                    configuration: .init(
                        isGrabberVisible: false,
                        dismissOnBackdropView: false,
                        skipThroughGestures: true
                    )
                )
            )
        } else {
            showViewSettings()
        }
    }

    func createObject() {
        let availableTemplates = searchService.searchTemplates(
            for: .dynamic(ObjectTypeProvider.shared.defaultObjectType.url)
        )
        let hasSingleTemplate = availableTemplates?.count == 1
        let templateId = hasSingleTemplate ? (availableTemplates?.first?.id ?? "") : ""

        guard let objectDetails = dataviewService.addRecord(templateId: templateId) else { return }
        
        router.showCreateObject(pageId: objectDetails.id)
    }
    
    func showViewSettings() {
        router.presentFullscreen(
            AnytypePopup(
                viewModel: EditorSetViewSettingsViewModel(
                    setModel: self,
                    service: dataviewService
                )
            )
        )
    }
    
    func showSorts() {
        router.presentFullscreen(
            AnytypePopup(
                viewModel: SetSortsListViewModel(
                    setModel: self,
                    service: dataviewService,
                    router: router
                )
            )
        )
    }
    
    func showFilters() {}
    
    func showObjectSettings() {
        router.showSettings()
    }
    
    func showAddNewRelationView(onSelect: @escaping (RelationMetadata, _ isNew: Bool) -> Void) {
        router.showAddNewRelationView(onSelect: onSelect)
    }
}
