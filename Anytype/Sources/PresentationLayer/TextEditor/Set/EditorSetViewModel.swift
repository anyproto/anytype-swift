import Combine
import BlocksModels
import AnytypeCore
import SwiftUI
import OrderedCollections

final class EditorSetViewModel: ObservableObject {
    @Published var titleString: String
    @Published var dataView = BlockDataview.empty
    @Published private(set) var headerModel: ObjectHeaderViewModel!
    @Published var loadingDocument = true
    @Published var featuredRelations = [Relation]()
    
    private var recordsDict: OrderedDictionary<SubscriptionId, [ObjectDetails]> = [:]
    @Published var configurationsDict: OrderedDictionary<SubscriptionId, [SetContentViewItemConfiguration]> = [:]
    @Published var pagitationData = EditorSetPaginationData.empty
    
    @Published var sorts: [SetSort] = []
    @Published var filters: [SetFilter] = []
    @Published var dataViewRelationsDetails: [RelationDetails] = []
    
    private let setSyncStatus = FeatureFlags.setSyncStatus
    @Published var syncStatus: SyncStatus = .unknown

    var isUpdating = false

    var isEmpty: Bool {
        dataView.views.isEmpty
    }
    
    var activeView: DataviewView {
        dataView.views.first { $0.id == dataView.activeViewId } ?? .empty
    }
    
    var colums: [RelationDetails] {
        sortedRelations.filter { $0.option.isVisible }.map(\.relationDetails)
    }
    
    var isSmallItemSize: Bool {
        activeView.cardSize == .small
    }
    
    var isGroupBackgroundColors: Bool {
        activeView.groupBackgroundColors
    }
    
    var contentViewType: SetContentViewType {
        activeView.type.setContentViewType
    }
    
    var sortedRelations: [SetRelation] {
        dataBuilder.sortedRelations(dataview: dataView, view: activeView)
    }
 
    var details: ObjectDetails? {
        document.details
    }

    func activeViewRelations(excludeRelations: [RelationDetails] = []) -> [RelationDetails] {
        dataBuilder.activeViewRelations(
            dataViewRelationsDetails: dataViewRelationsDetails,
            view: activeView,
            excludeRelations: excludeRelations
        )
    }

    private var isObjectLocked: Bool {
        document.isLocked ||
        activeView.type == .gallery ||
        (FeatureFlags.setListView && activeView.type == .list)
    }
    
    let document: BaseDocument
    private var router: EditorRouterProtocol!

    let paginationHelper = EditorSetPaginationHelper()
    private let subscriptionService = ServiceLocator.shared.subscriptionService()
    private let dataBuilder = SetContentViewDataBuilder()
    private let dataviewService: DataviewServiceProtocol
    private let searchService: SearchServiceProtocol
    private let detailsService: DetailsServiceProtocol
    private let textService: TextServiceProtocol
    private let relationSearchDistinctService: RelationSearchDistinctServiceProtocol
    private let setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol
    private var subscriptions = [AnyCancellable]()
    private var titleSubscription: AnyCancellable?
    private let relationDetailsStorage: RelationDetailsStorageProtocol

    init(
        document: BaseDocument,
        dataviewService: DataviewServiceProtocol,
        searchService: SearchServiceProtocol,
        detailsService: DetailsServiceProtocol,
        textService: TextServiceProtocol,
        relationDetailsStorage: RelationDetailsStorageProtocol,
        relationSearchDistinctService: RelationSearchDistinctServiceProtocol,
        setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol
    ) {
        self.document = document
        self.dataviewService = dataviewService
        self.searchService = searchService
        self.detailsService = detailsService
        self.textService = textService
        self.relationDetailsStorage = relationDetailsStorage
        self.relationSearchDistinctService = relationSearchDistinctService
        self.setSubscriptionDataBuilder = setSubscriptionDataBuilder

        self.titleString = document.details?.pageCellTitle ?? ""
        self.featuredRelations = document.featuredRelationsForEditor
    }
    
    func setup(router: EditorRouterProtocol) {
        self.router = router
        self.headerModel = ObjectHeaderViewModel(document: document, router: router, isOpenedForPreview: false)
        
        document.updatePublisher.sink { [weak self] in
            self?.onDataChange($0)
        }.store(in: &subscriptions)

        Task { @MainActor in
            do {
                try await document.open()
                loadingDocument = false
                setupDataview()

                if let details = document.details, details.setOf.isEmpty {
                    showSetOfTypeSelection()
                }
            } catch {
                router.goBack()
            }
        }
    }
    
    func onAppear() {
        startSubscriptionIfNeeded()
        router?.setNavigationViewHidden(false, animated: true)
    }
    
    func onWillDisappear() {
        router.dismissSetSettingsIfNeeded()
    }
    
    func onDisappear() {
        subscriptionService.stopAllSubscriptions()
    }

    func onRelationTap(relation: Relation) {
        AnytypeAnalytics.instance().logChangeRelationValue(type: .set)
        showRelationValueEditingView(key: relation.key, source: .object)
    }

    func updateActiveViewId(_ id: BlockId) {
        updateDataview(with: id)
        setupDataview()
    }
    
    func startSubscriptionIfNeeded() {
        guard !isEmpty else {
            subscriptionService.stopAllSubscriptions()
            return
        }
        
        if activeView.type.hasGroups {
            setupGroupSubscriptions()
        } else {
            startSubscriptionIfNeeded(with: SubscriptionId.set)
        }
    }
    
    // MARK: - Private
    
    private func setupGroupSubscriptions() {
        Task {
            let groups = try await relationSearchDistinctService.searchDistinct(
                relationKey: activeView.groupRelationKey,
                filters: activeView.filters
            )
            groups.forEach { [weak self] group in
                guard let self else { return }
                let groupFilter = group.filter(with: self.activeView.groupRelationKey)
                let subscriptionId = SubscriptionId(value: "\(self.document.objectId)-dataview:\(group.id)")
                self.startSubscriptionIfNeeded(with: subscriptionId, groupFilter: groupFilter)
            }
        }
    }
    
    private func startSubscriptionIfNeeded(with subscriptionId: SubscriptionId, groupFilter: DataviewFilter? = nil) {
        let data = setSubscriptionDataBuilder.set(
            .init(
                identifier: subscriptionId,
                dataView: dataView,
                view: activeView,
                groupFilter: groupFilter,
                currentPage: max(pagitationData.selectedPage, 1) // show first page for empty request
            )
        )
        
        if subscriptionService.hasSubscriptionDataDiff(with: data) || recordsDict.keys.isEmpty {
            restartSubscription(with: data)
        }
    }
    
    private func restartSubscription(with data: SubscriptionData) {
        subscriptionService.stopSubscription(id: data.identifier)
        subscriptionService.startSubscription(data: data) { subId, update in
            DispatchQueue.main.async { [weak self] in
                self?.updateData(with: subId, update: update)
            }
        }
    }
    
    private func updateData(with subscriptionId: SubscriptionId, update: SubscriptionUpdate) {
        if case let .pageCount(count) = update {
            updatePageCount(count)
            return
        }
        
        updateRecords(for: subscriptionId, update: update)
        updateConfigurations(with: [subscriptionId])
    }
    
    private func updateRecords(for subscriptionId: SubscriptionId, update: SubscriptionUpdate) {
        var records = recordsDict[subscriptionId, default: []]
        records.applySubscriptionUpdate(update)
        recordsDict[subscriptionId] = records
    }
    
    private func updateConfigurations(with subscriptionIds: [SubscriptionId]) {
        for subscriptionId in subscriptionIds {
            if let records = recordsDict[subscriptionId] {
                let configurations = dataBuilder.itemData(
                    records,
                    dataView: dataView,
                    activeView: activeView,
                    isObjectLocked: isObjectLocked,
                    onIconTap: { [weak self] details in
                        self?.updateDetailsIfNeeded(details)
                    },
                    onItemTap: { [weak self] details in
                        self?.itemTapped(details)
                    }
                )
                configurationsDict[subscriptionId] = configurations
            }
        }
    }
    
    private func onDataChange(_ data: DocumentUpdate) {
        switch data {
        case .general, .blocks, .details, .dataSourceUpdate:
            setupDataview()
        case .syncStatus(let status):
            if setSyncStatus {
                syncStatus = status
            }
        case .header:
            break // handled in ObjectHeaderViewModel
        }
    }
    
    private func setupDataview() {
        isUpdating = true

        anytypeAssert(document.dataviews.count < 2, "\(document.dataviews.count) dataviews in set", domain: .editorSet)
        document.dataviews.first.flatMap { dataView in
            anytypeAssert(dataView.views.isNotEmpty, "Empty views in dataview: \(dataView)", domain: .editorSet)
        }
        let prevActiveView = activeView
        self.dataView = document.dataviews.first ?? .empty
        clearRecordsIfNeeded(prevActiveView: prevActiveView)

        if let details = document.details {
            titleString = details.pageCellTitle

            titleSubscription = $titleString.sink { [weak self] newValue in
                guard let self = self, !self.isUpdating else { return }

                if newValue.contains(where: \.isNewline) {
                    self.isUpdating = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { // Return button tapped on keyboard. Waiting for iOS 15 support!!!
                        self.titleString = newValue.trimmingCharacters(in: .newlines)
                    }
                    UIApplication.shared.hideKeyboard()
                    return
                }

                self.textService.setText(
                    contextId: self.document.objectId,
                    blockId: RelationKey.title.rawValue,
                    middlewareString: .init(text: newValue, marks: .init())
                )

                self.isUpdating = false
            }
        }

        updateDataViewRelations()
        updateActiveViewId()
        updateSorts()
        updateFilters()
        startSubscriptionIfNeeded()
        updateConfigurations(with: Array(recordsDict.keys))
        featuredRelations = document.featuredRelationsForEditor

        isUpdating = false
    }
    
    private func clearRecordsIfNeeded(prevActiveView: DataviewView) {
        let modeChanged = (prevActiveView.type.hasGroups && !activeView.type.hasGroups) ||
        (!prevActiveView.type.hasGroups && activeView.type.hasGroups)
        
        let groupRelationKeyChanged = prevActiveView.groupRelationKey != activeView.groupRelationKey
        
        if modeChanged || groupRelationKeyChanged {
            recordsDict = [:]
            configurationsDict = [:]
            subscriptionService.stopAllSubscriptions()
        }
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
    
    private func updateDataViewRelations() {
        dataViewRelationsDetails = relationDetailsStorage.relationsDetails(for: dataView.relationLinks)
    }
    
    private func isBookmarksSet() -> Bool {
        dataView.source.contains(ObjectTypeId.BundledTypeId.bookmark.rawValue)
    }
    
    private func isNotesSet() -> Bool {
        dataView.source.contains(ObjectTypeId.BundledTypeId.note.rawValue)
    }
    
    private func updateDetailsIfNeeded(_ details: ObjectDetails) {
        guard details.layoutValue == .todo else { return }
        detailsService.updateBundledDetails(
            contextID: details.id,
            bundledDpdates: [.done(!details.isDone)]
        )
    }
    
    private func itemTapped(_ details: ObjectDetails) {
        openObject(pageId: details.id, type: details.editorViewType)
    }
}

// MARK: - Routing
extension EditorSetViewModel {

    func showRelationValueEditingView(key: String, source: RelationSource) {
        if key == BundledRelationKey.setOf.rawValue {
            showSetOfTypeSelection()
            
            return
        }

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
        router.showViewPicker(setModel: self, dataviewService: dataviewService) { [weak self] activeView in
            self?.showViewTypes(with: activeView)
        }
    }
    
    func showSetSettings() {
        router.showSetSettings(setModel: self)
    }

    func createObject() {
        if isBookmarksSet() {
            createBookmarkObject()
        } else {
            createDefaultObject()
        }
    }
    
    func showViewTypes(with activeView: DataviewView?) {
        router.showViewTypes(
            activeView: activeView,
            canDelete: dataView.views.count > 1,
            dataviewService: dataviewService
        )
    }

    func showViewSettings() {
        router.showViewSettings(
            setModel: self,
            dataviewService: dataviewService
        )
    }
    
    func showSorts() {
        router.showSorts(
            setModel: self,
            dataviewService: dataviewService
        )
    }
    
    func showFilters() {
        router.showFilters(
            setModel: self,
            dataviewService: dataviewService
        )
    }
    
    func showObjectSettings() {
        router.showSettings()
    }
    
    func showAddNewRelationView(onSelect: @escaping (RelationDetails, _ isNew: Bool) -> Void) {
        router.showAddNewRelationView(onSelect: onSelect)
    }


    private func showSetOfTypeSelection() {
        router.showTypesSearch(title: Loc.Set.SourceType.selectSource, selectedObjectId: document.details?.setOf.first) { [unowned self] typeObjectId in
            Task { @MainActor in
                try? await dataviewService.setSource(typeObjectId: typeObjectId)
            }
        }
    }
    
    private func createDefaultObject() {
        let objectType = dataView.source.first
        let templateId: String
        if let objectType = objectType {
            let availableTemplates = searchService.searchTemplates(
                for: .dynamic(objectType)
            )
            let hasSingleTemplate = availableTemplates?.count == 1
            templateId = hasSingleTemplate ? (availableTemplates?.first?.id ?? "") : ""
        } else {
            templateId = ""
        }

        Task { @MainActor in

            let objectId = try await dataviewService.addRecord(
                objectType: objectType ?? "",
                templateId: templateId,
                setFilters: filters
            )
            
            handleCreatedObjectId(objectId)
        }
    }
    
    private func handleCreatedObjectId(_ objectId: String) {
        if isNotesSet() {
            openObject(pageId: objectId, type: .page)
        } else {
            router.showCreateObject(pageId: objectId)
        }
    }
    
    private func openObject(pageId: BlockId, type: EditorViewType) {
        let screenData = EditorScreenData(pageId: pageId, type: type)
        router.showPage(data: screenData)
    }
    
    private func createBookmarkObject() {
        router.showCreateBookmarkObject()
    }
}

extension EditorSetViewModel {
    static let urlRelationKey = "url"
}

extension EditorSetViewModel {
    static let empty = EditorSetViewModel(
        document: BaseDocument(objectId: "objectId"),
        dataviewService: DataviewService(objectId: "objectId", prefilledFieldsBuilder: SetFilterPrefilledFieldsBuilder()),
        searchService: ServiceLocator.shared.searchService(),
        detailsService: DetailsService(objectId: "objectId", service: ObjectActionsService()),
        textService: TextService(),
        relationDetailsStorage: ServiceLocator.shared.relationDetailsStorage(),
        relationSearchDistinctService: RelationSearchDistinctService(),
        setSubscriptionDataBuilder: SetSubscriptionDataBuilder()
    )
}
