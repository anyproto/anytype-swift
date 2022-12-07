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
    
    private var recordsDict: OrderedDictionary<String, [ObjectDetails]> = [:]
    private var groups: [DataviewGroup] = [] {
        didSet {
            startSubscriptionsByGroups()
        }
    }
    @Published var configurationsDict: OrderedDictionary<String, [SetContentViewItemConfiguration]> = [:]
    @Published var pagitationDataDict: OrderedDictionary<String, EditorSetPaginationData> = [:]
    
    @Published var sorts: [SetSort] = []
    @Published var filters: [SetFilter] = []
    @Published var dataViewRelationsDetails: [RelationDetails] = []
    
    private let setSyncStatus = FeatureFlags.setSyncStatus
    @Published var syncStatus: SyncStatus = .unknown
    @Published private var isAppear: Bool = false
    
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
    
    func groupBackgroundColor(for groupId: String) -> BlockBackgroundColor {
        guard let groupOrder = dataView.groupOrders.first(where: { $0.viewID == activeView.id }),
            let viewGroup = groupOrder.viewGroups.first(where: { $0.groupID == groupId }),
            let middlewareColor = MiddlewareColor(rawValue: viewGroup.backgroundColor) else {
            return BlockBackgroundColor.gray
        }
        return middlewareColor.backgroundColor
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
    private let groupsSubscriptionsHandler: GroupsSubscriptionsHandlerProtocol
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
        groupsSubscriptionsHandler: GroupsSubscriptionsHandlerProtocol,
        setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol
    ) {
        self.document = document
        self.dataviewService = dataviewService
        self.searchService = searchService
        self.detailsService = detailsService
        self.textService = textService
        self.relationDetailsStorage = relationDetailsStorage
        self.groupsSubscriptionsHandler = groupsSubscriptionsHandler
        self.setSubscriptionDataBuilder = setSubscriptionDataBuilder

        self.titleString = document.details?.pageCellTitle ?? ""
    }
    
    func setup(router: EditorRouterProtocol) {
        self.router = router
        self.headerModel = ObjectHeaderViewModel(document: document, router: router, isOpenedForPreview: false)
        
        document.updatePublisher.sink { [weak self] in
            self?.onDataChange($0)
        }.store(in: &subscriptions)

        Publishers.CombineLatest(document.detailsPublisher, $isAppear)
            .sink { [weak self] in self?.handleDetails(details: $0, isAppear: $1) }
            .store(in: &subscriptions)
        
        Task { @MainActor in
            do {
                try await document.open()
                loadingDocument = false
                setupDataview()

                if let details = document.details, details.setOf.isEmpty {
                    showSetOfTypeSelection()
                }
            } catch {
                router.closeEditor()
            }
        }
    }
    
    func onAppear() {
        startSubscriptionIfNeeded()
        router?.setNavigationViewHidden(false, animated: true)
        isAppear = true
    }
    
    func onWillDisappear() {
        router.dismissSetSettingsIfNeeded()
        isAppear = false
    }
    
    func onDisappear() {
        subscriptionService.stopAllSubscriptions()
        groupsSubscriptionsHandler.stopAllSubscriptions()
    }

    func onRelationTap(relation: Relation) {
        if relation.hasSelectedObjectsRelationType {
            router.showFailureToast(message: Loc.Set.SourceType.Cancel.Toast.title)
        } else {
            AnytypeAnalytics.instance().logChangeRelationValue(type: .set)
            showRelationValueEditingView(key: relation.key, source: .object)
        }
    }

    func updateActiveViewId(_ id: BlockId) {
        updateDataview(with: id)
        setupDataview()
    }
    
    func startSubscriptionIfNeeded(forceUpdate: Bool = false) {
        guard !isEmpty else {
            subscriptionService.stopAllSubscriptions()
            return
        }
        
        if activeView.type.hasGroups {
            setupGroupsSubscription(forceUpdate: forceUpdate)
        } else {
            setupPaginationDataIfNeeded(groupId: SubscriptionId.set.value)
            startSubscriptionIfNeeded(with: SubscriptionId.set)
        }
    }
    
    func updateObjectDetails(_ detailsId: String, groupId: String) {
        guard let group = groups.first(where: { $0.id == groupId }),
        let value = group.value else { return }

        detailsService.updateDetails(
            contextId: detailsId,
            relationKey: activeView.groupRelationKey,
            value: value
        )
    }
    
    func pagitationData(by groupId: String) -> EditorSetPaginationData {
        pagitationDataDict[groupId] ?? EditorSetPaginationData.empty
    }
    
    // MARK: - Private
    
    private func setupGroupsSubscription(forceUpdate: Bool) {
        Task { @MainActor in
            let data = GroupsSubscription(
                identifier: SubscriptionId.setGroups,
                relationKey: activeView.groupRelationKey,
                filters: activeView.filters,
                source: dataView.source
            )
            if groupsSubscriptionsHandler.hasGroupsSubscriptionDataDiff(with: data) {
                groupsSubscriptionsHandler.stopAllSubscriptions()
                groups = try await startGroupsSubscription(with: data)
            }
            
            
            if forceUpdate || checkGroupOrderUpdates() {
                startSubscriptionsByGroups()
            }
        }
    }
    
    private func checkGroupOrderUpdates() -> Bool {
        let groupOrder = dataView.groupOrders.first { $0.viewID == activeView.id }
        let visibleViewGroups = groupOrder?.viewGroups.filter { !$0.hidden }
        let newVisible = visibleViewGroups?.first { recordsDict[$0.groupID] == nil }
        
        let hiddenViewGroups = groupOrder?.viewGroups.filter { $0.hidden }
        var hasNewHidden = false
        hiddenViewGroups?.forEach { group in
            if recordsDict[group.groupID] != nil {
                hasNewHidden = true
                recordsDict[group.groupID] = nil
                configurationsDict[group.groupID] = nil
                subscriptionService.stopSubscription(id: SubscriptionId(value: group.groupID))
            }
        }
        
        return newVisible != nil || hasNewHidden
    }
    
    private func startGroupsSubscription(with data: GroupsSubscription) async throws -> [DataviewGroup] {
        try await groupsSubscriptionsHandler.startGroupsSubscription(data: data) { [weak self] group, remove in
            guard let self else { return }
            if remove {
                self.groups = self.groups.filter { $0 != group }
            } else {
                self.groups.append(group)
            }
        }
    }
    
    private func startSubscriptionsByGroups() {
        sortedVisibleGroups().forEach { [weak self] group in
            guard let self else { return }
            let groupFilter = group.filter(with: self.activeView.groupRelationKey)
            let subscriptionId = SubscriptionId(value: group.id)
            self.setupPaginationDataIfNeeded(groupId: group.id)
            self.startSubscriptionIfNeeded(with: subscriptionId, groupFilter: groupFilter)
        }
    }
    
    private func setupPaginationDataIfNeeded(groupId: String) {
        guard pagitationDataDict[groupId] == nil else { return }
        pagitationDataDict[groupId] = EditorSetPaginationData.empty
    }
    
    private func startSubscriptionIfNeeded(with subscriptionId: SubscriptionId, groupFilter: DataviewFilter? = nil) {
        let pagitationData = pagitationData(by: subscriptionId.value)
        let currentPage: Int
        let numberOfRowsPerPage: Int
        if activeView.type.hasGroups {
            numberOfRowsPerPage = UserDefaultsConfig.rowsPerPageInGroupedSet * max(pagitationData.selectedPage, 1)
            currentPage = 1
        } else {
            numberOfRowsPerPage = UserDefaultsConfig.rowsPerPageInSet
            currentPage = max(pagitationData.selectedPage, 1)
        }
        
        let data = setSubscriptionDataBuilder.set(
            .init(
                identifier: subscriptionId,
                dataView: dataView,
                view: activeView,
                groupFilter: groupFilter,
                currentPage: currentPage, // show first page for empty request
                numberOfRowsPerPage: numberOfRowsPerPage
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
                self?.updateData(with: subId.value, update: update)
            }
        }
    }
    
    private func updateData(with groupId: String, update: SubscriptionUpdate) {
        if case let .pageCount(count) = update {
            updatePageCount(count, groupId: groupId, ignorePageLimit: activeView.type.hasGroups)
            return
        }
        
        updateRecords(for: groupId, update: update)
        updateConfigurations(with: [groupId])
    }
    
    private func updateRecords(for groupId: String, update: SubscriptionUpdate) {
        var records = recordsDict[groupId, default: []]
        records.applySubscriptionUpdate(update)
        recordsDict[groupId] = records
    }
    
    private func updateConfigurations(with groupIds: [String]) {
        var tempConfigurationsDict = configurationsDict
        for groupId in groupIds {
            if let records = sortedRecords(with: groupId) {
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
                tempConfigurationsDict[groupId] = configurations
            }
        }
        configurationsDict = sortedConfigurationsDict(with: tempConfigurationsDict)
    }
    
    private func sortedConfigurationsDict(
        with dict: OrderedDictionary<String, [SetContentViewItemConfiguration]>
    ) -> OrderedDictionary<String, [SetContentViewItemConfiguration]> {
        let sortedViewGroups = sortedViewGroups()
        guard sortedViewGroups.isNotEmpty else { return dict }
        
        let groupIds = Array(dict.keys).sorted { (a, b) -> Bool in
            let first = sortedViewGroups.firstIndex { $0.groupID == a }
            let second = sortedViewGroups.firstIndex { $0.groupID == b }
            if let first, let second {
                return first < second
            }
            return false
        }
        
        var sortedConfigurationsDict: OrderedDictionary<String, [SetContentViewItemConfiguration]> = [:]
        groupIds.forEach { subId in
            if let records = dict[subId] {
                sortedConfigurationsDict[subId] = records
            }
        }
        
        return sortedConfigurationsDict
    }
    
    private func sortedViewGroups() -> [DataviewViewGroup] {
        let neededGroupOrder = dataView.groupOrders.first { [weak self] groupOrder in
            groupOrder.viewID == self?.activeView.id
        }
        
        guard let neededGroupOrder else {
            return []
        }
        
        let sortedViewGroups = neededGroupOrder.viewGroups.sorted { (a, b) -> Bool in
            return a.index < b.index
        }
        return sortedViewGroups.map { $0 }
    }
    
    private func sortedVisibleGroups() -> [DataviewGroup] {
        let sortedViewGroups = sortedViewGroups()
        guard sortedViewGroups.isNotEmpty else { return groups }
        let hiddenSortedViewGroupsIds = sortedViewGroups.filter { $0.hidden }.map { $0.groupID }
        let visibleGroups = groups.filter { !hiddenSortedViewGroupsIds.contains($0.id) }
        
        return visibleGroups.sorted { (a, b) -> Bool in
            let first = sortedViewGroups.firstIndex { $0.groupID == a.id }
            let second = sortedViewGroups.firstIndex { $0.groupID == b.id }
            if let first, let second {
                return first < second
            }
            return second == nil
        }
    }
    
    private func sortedRecords(with groupId: String) -> [ObjectDetails]? {
        let neededObjectOrder = dataView.objectOrders.first { [weak self] objectOrder in
            objectOrder.viewID == self?.activeView.id && objectOrder.groupID == groupId
        }
        guard let neededObjectOrder,
                neededObjectOrder.objectIds.isNotEmpty,
              let records = recordsDict[groupId] else {
            return recordsDict[groupId]
        }
        
        return records.sorted { (a, b) -> Bool in
            if let first = neededObjectOrder.objectIds.firstIndex(of: a.id),
               let second = neededObjectOrder.objectIds.firstIndex(of: b.id)
            {
                return first < second
            }
            return false
        }
    }
    
    private func handleDetails(details: ObjectDetails, isAppear: Bool) {
        if details.isArchived && isAppear {
            router.closeEditor()
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
        // Show for empty state
        featuredRelations = document.featuredRelationsForEditor
        
        guard document.dataviews.isNotEmpty else { return }
        anytypeAssert(document.dataviews.count < 2, "\(document.dataviews.count) dataviews in set", domain: .editorSet)
        
        isUpdating = true

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

        isUpdating = false
    }
    
    private func clearRecordsIfNeeded(prevActiveView: DataviewView) {
        let modeChanged = (prevActiveView.type.hasGroups && !activeView.type.hasGroups) ||
        (!prevActiveView.type.hasGroups && activeView.type.hasGroups)
        
        let groupRelationKeyChanged = prevActiveView.groupRelationKey != activeView.groupRelationKey
        
        if modeChanged || groupRelationKeyChanged {
            recordsDict = [:]
            configurationsDict = [:]
            pagitationDataDict = [:]
            groups = []
            subscriptionService.stopAllSubscriptions()
            groupsSubscriptionsHandler.stopAllSubscriptions()
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
    
    private func isRelationsSet() -> Bool {
        let relation = document.parsedRelations.all.first { $0.key == BundledRelationKey.setOf.rawValue }
        if let relation, relation.hasSelectedObjectsRelationType {
            return true
        } else {
            return false
        }
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
        } else if isRelationsSet() {
            let relationsDetails = dataViewRelationsDetails.filter { dataView.source.contains($0.id) }
            createObject(
                with: ObjectTypeProvider.shared.defaultObjectType.id,
                relationsDetails: relationsDetails
            )
        } else {
            createObject(
                with: dataView.source.first ?? "",
                relationsDetails: []
            )
        }
    }
    
    func showViewTypes(with activeView: DataviewView?) {
        router.showViewTypes(
            dataView: dataView,
            activeView: activeView,
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
    
    func objectOrderUpdate(with groupObjectIds: [GroupObjectIds]) {
        Task {
            try await dataviewService.objectOrderUpdate(
                viewId: activeView.id,
                groupObjectIds: groupObjectIds
            )
        }
    }
    
    func showKanbanColumnSettings(for groupId: String) {
        let groupOrder = dataView.groupOrders.first { $0.viewID == activeView.id }
        let viewGroup = groupOrder?.viewGroups.first { $0.groupID == groupId }
        let selectedColor = MiddlewareColor(rawValue: viewGroup?.backgroundColor ?? "")?.backgroundColor
        router.showKanbanColumnSettings(
            hideColumn: viewGroup?.hidden ?? false,
            selectedColor: selectedColor,
            onSelect: { [weak self] hidden, backgroundColor in
                self?.dataviewGroupOrderUpdate(
                    groupId: groupId,
                    hidden: hidden,
                    backgroundColor: backgroundColor
                )
            }
        )
    }
    
    private func dataviewGroupOrderUpdate(groupId: String, hidden: Bool, backgroundColor: BlockBackgroundColor?) {
        let updatedGroupOrder = updatedGroupOrder(groupId: groupId, hidden: hidden, backgroundColor: backgroundColor)
        Task {
            try await dataviewService.groupOrderUpdate(
                viewId: activeView.id,
                groupOrder: updatedGroupOrder
            )
        }
    }
    
    private func updatedGroupOrder(groupId: String, hidden: Bool, backgroundColor: BlockBackgroundColor?) -> DataviewGroupOrder {
        let groupOrder = dataView.groupOrders.first { $0.viewID == activeView.id } ?? DataviewGroupOrder.create(viewID: activeView.id)
        var viewGroups = groupOrder.viewGroups
        let viewGroupIndex = viewGroups.firstIndex { $0.groupID == groupId }
        let viewGroup: DataviewViewGroup
        if let viewGroupIndex {
            viewGroup = viewGroups[viewGroupIndex]
                .updated(
                    hidden: hidden,
                    backgroundColor: backgroundColor?.middleware.rawValue
                )
            viewGroups[viewGroupIndex] = viewGroup
        } else {
            viewGroup = DataviewViewGroup.create(
                groupId: groupId,
                index: groups.count + 1,
                hidden: hidden,
                backgroundColor: backgroundColor?.middleware.rawValue
            )
            viewGroups.append(viewGroup)
        }
        return groupOrder.updated(viewGroups: viewGroups)
    }
    
    private func showSetOfTypeSelection() {
        router.showSources(selectedObjectId: document.details?.setOf.first) { [unowned self] typeObjectId in
            Task { @MainActor in
                try? await dataviewService.setSource(typeObjectId: typeObjectId)
            }
        }
    }
    
    private func createObject(with type: String, relationsDetails: [RelationDetails]) {
        let templateId: String
        if type.isNotEmpty {
            let availableTemplates = searchService.searchTemplates(
                for: .dynamic(type)
            )
            let hasSingleTemplate = availableTemplates?.count == 1
            templateId = hasSingleTemplate ? (availableTemplates?.first?.id ?? "") : ""
        } else {
            templateId = ""
        }

        Task { @MainActor in

            let objectId = try await dataviewService.addRecord(
                objectType: type,
                templateId: templateId,
                setFilters: filters,
                relationsDetails: relationsDetails
            )
            
            handleCreatedObjectId(objectId, type: type)
        }
    }
    
    private func handleCreatedObjectId(_ objectId: String, type: String) {
        if type == ObjectTypeId.BundledTypeId.note.rawValue {
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
        dataviewService: DataviewService(objectId: "objectId", prefilledFieldsBuilder: SetPrefilledFieldsBuilder()),
        searchService: ServiceLocator.shared.searchService(),
        detailsService: DetailsService(objectId: "objectId", service: ObjectActionsService()),
        textService: TextService(),
        relationDetailsStorage: ServiceLocator.shared.relationDetailsStorage(),
        groupsSubscriptionsHandler: ServiceLocator.shared.groupsSubscriptionsHandler(),
        setSubscriptionDataBuilder: SetSubscriptionDataBuilder()
    )
}
