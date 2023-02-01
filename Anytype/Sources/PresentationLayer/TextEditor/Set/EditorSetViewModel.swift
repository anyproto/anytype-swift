import Combine
import BlocksModels
import AnytypeCore
import SwiftUI
import OrderedCollections

final class EditorSetViewModel: ObservableObject {
    @Published var titleString: String
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
    
    @Published var syncStatus: SyncStatus = .unknown
    @Published private var isAppear: Bool = false
    
    var isUpdating = false

    var objectId: BlocksModels.BlockId {
        setDocument.objectId
    }
    
    var activeView: DataviewView {
        setDocument.activeView
    }
    
    var isEmpty: Bool {
        setDocument.dataView.views.isEmpty
    }
    
    var colums: [RelationDetails] {
        setDocument.sortedRelations.filter { $0.option.isVisible }.map(\.relationDetails)
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
    
    var details: ObjectDetails? {
        setDocument.details
    }
    
    var hasTargetObjectId: Bool {
        setDocument.targetObjectID != nil
    }
    
    var showSetEmptyState: Bool {
        setDocument.details?.setOf.first { $0.isNotEmpty } == nil
    }
    
    func groupBackgroundColor(for groupId: String) -> BlockBackgroundColor {
        guard let groupOrder = setDocument.dataView.groupOrders.first(where: { [weak self] in $0.viewID == self?.activeView.id }),
            let viewGroup = groupOrder.viewGroups.first(where: { $0.groupID == groupId }),
            let middlewareColor = MiddlewareColor(rawValue: viewGroup.backgroundColor) else {
            return groupFirstOptionBackgroundColor(for: groupId)
        }
        return middlewareColor.backgroundColor
    }
    
    func headerType(for groupId: String) -> SetKanbanColumnHeaderType {
        guard let group = groups.first(where: { $0.id == groupId }) else { return .uncategorized }
        return group.header(with: activeView.groupRelationKey)
    }
    
    private func groupFirstOptionBackgroundColor(for groupId: String) -> BlockBackgroundColor {
        guard let backgroundColor = groups.first(where: { $0.id == groupId })?.backgroundColor else {
            return BlockBackgroundColor.gray
        }
        return backgroundColor
    }
    
    private let setDocument: SetDocumentProtocol
    private var router: EditorSetRouterProtocol?
    
    let paginationHelper = EditorSetPaginationHelper()
    private let subscriptionService: SubscriptionsServiceProtocol
    private let dataBuilder = SetContentViewDataBuilder()
    private let dataviewService: DataviewServiceProtocol
    private let searchService: SearchServiceProtocol
    private let detailsService: DetailsServiceProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    private let textService: TextServiceProtocol
    private let groupsSubscriptionsHandler: GroupsSubscriptionsHandlerProtocol
    private let setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol
    private var subscriptions = [AnyCancellable]()
    private var titleSubscription: AnyCancellable?

    init(
        setDocument: SetDocumentProtocol,
        subscriptionService: SubscriptionsServiceProtocol,
        dataviewService: DataviewServiceProtocol,
        searchService: SearchServiceProtocol,
        detailsService: DetailsServiceProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        textService: TextServiceProtocol,
        groupsSubscriptionsHandler: GroupsSubscriptionsHandlerProtocol,
        setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol
    ) {
        self.setDocument = setDocument
        self.subscriptionService = subscriptionService
        self.dataviewService = dataviewService
        self.searchService = searchService
        self.detailsService = detailsService
        self.objectActionsService = objectActionsService
        self.textService = textService
        self.groupsSubscriptionsHandler = groupsSubscriptionsHandler
        self.setSubscriptionDataBuilder = setSubscriptionDataBuilder

        self.titleString = setDocument.details?.pageCellTitle ?? ""
    }
    
    func setup(router: EditorSetRouterProtocol) {
        self.router = router
        self.headerModel = ObjectHeaderViewModel(document: setDocument, router: router, isOpenedForPreview: false)
        
        setDocument.setUpdatePublisher.sink { [weak self] in
            self?.onDataChange($0)
        }.store(in: &subscriptions)

        Publishers.CombineLatest(setDocument.document.detailsPublisher, $isAppear)
            .sink { [weak self] in self?.handleDetails(details: $0, isAppear: $1) }
            .store(in: &subscriptions)
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await self.setDocument.open()
                self.loadingDocument = false
                self.onDataviewUpdate()
            } catch {
                self.router?.closeEditor()
            }
        }
    }
    
    func onAppear() {
        startSubscriptionIfNeeded()
        router?.setNavigationViewHidden(false, animated: true)
        isAppear = true
    }
    
    func onWillDisappear() {
        router?.dismissSetSettingsIfNeeded()
        isAppear = false
    }
    
    func onDisappear() {
        subscriptionService.stopAllSubscriptions()
        groupsSubscriptionsHandler.stopAllSubscriptions()
    }

    func onRelationTap(relation: Relation) {
        if relation.hasSelectedObjectsRelationType {
            router?.showFailureToast(message: Loc.Set.SourceType.Cancel.Toast.title)
        } else {
            AnytypeAnalytics.instance().logChangeRelationValue(type: .set)
            showRelationValueEditingView(key: relation.key)
        }
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
    
    private func onDataChange(_ update: SetDocumentUpdate) {
        switch update {
        case .dataviewUpdated(clearState: let clearState):
            onDataviewUpdate(clearState: clearState)
        case .syncStatus(let status):
            syncStatus = status
        }
    }
    
    private func onDataviewUpdate(clearState: Bool = false) {
        // Show for empty state
        featuredRelations = setDocument.featuredRelationsForEditor
        
        guard setDocument.dataviews.isNotEmpty else { return }
        anytypeAssert(setDocument.dataviews.count < 2, "\(setDocument.dataviews.count) dataviews in set", domain: .editorSet)
        setDocument.dataviews.first.flatMap { dataView in
            anytypeAssert(dataView.views.isNotEmpty, "Empty views in dataview: \(dataView)", domain: .editorSet)
        }
        
        isUpdating = true
        
        if clearState {
            self.clearState()
        }
        setupTitle()
        startSubscriptionIfNeeded()
        updateConfigurations(with: Array(recordsDict.keys))

        isUpdating = false
    }
    
    private func setupTitle() {
        if let details = setDocument.details {
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
                    contextId: self.setDocument.targetObjectID ?? self.objectId,
                    blockId: RelationKey.title.rawValue,
                    middlewareString: .init(text: newValue, marks: .init())
                )

                self.isUpdating = false
            }
        }
    }
    
    // MARK: - Groups Subscriptions
    
    private func setupGroupsSubscription(forceUpdate: Bool) {
        Task { @MainActor [weak self] in
            guard let self, let source = self.details?.setOf, source.isNotEmpty else { return }
            let data = GroupsSubscription(
                identifier: SubscriptionId.setGroups,
                relationKey: self.activeView.groupRelationKey,
                filters: self.activeView.filters,
                source: source
            )
            if self.groupsSubscriptionsHandler.hasGroupsSubscriptionDataDiff(with: data) {
                self.groupsSubscriptionsHandler.stopAllSubscriptions()
                self.groups = try await self.startGroupsSubscription(with: data)
            }
            
            if forceUpdate || self.checkGroupOrderUpdates() {
                self.startSubscriptionsByGroups()
            }
        }
    }
    
    private func checkGroupOrderUpdates() -> Bool {
        let groupOrder = setDocument.dataView.groupOrders.first { [weak self] in $0.viewID == self?.activeView.id }
        let visibleViewGroups = groupOrder?.viewGroups.filter { !$0.hidden }
        let newVisible = visibleViewGroups?.first { [weak self] in self?.recordsDict[$0.groupID] == nil }
        
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
        
        guard let source = details?.setOf, source.isNotEmpty else { return }
        
        let data = setSubscriptionDataBuilder.set(
            .init(
                identifier: subscriptionId,
                source: source,
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
                    dataView: setDocument.dataView,
                    activeView: activeView,
                    isObjectLocked: setDocument.isObjectLocked,
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
        let neededGroupOrder = setDocument.dataView.groupOrders.first { [weak self] groupOrder in
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
        let neededObjectOrder = setDocument.dataView.objectOrders.first { [weak self] objectOrder in
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
            router?.closeEditor()
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
    
    private func clearState() {
        recordsDict = [:]
        configurationsDict = [:]
        pagitationDataDict = [:]
        groups = []
        subscriptionService.stopAllSubscriptions()
        groupsSubscriptionsHandler.stopAllSubscriptions()
    }
    
    func createObject() {
        if setDocument.isBookmarksSet() {
            createBookmarkObject()
        } else if setDocument.isRelationsSet() {
            let relationsDetails = setDocument.dataViewRelationsDetails.filter { [weak self] detail in
                guard let source = self?.details?.setOf else { return false }
                return source.contains(detail.id)
            }
            createObject(
                with: ObjectTypeProvider.shared.defaultObjectType.id,
                relationsDetails: relationsDetails
            )
        } else {
            createObject(
                with: details?.setOf.first ?? "",
                relationsDetails: []
            )
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

        Task { @MainActor [weak self] in
            guard let self else { return }
            let objectId = try await self.dataviewService.addRecord(
                objectType: type,
                templateId: templateId,
                setFilters: self.setDocument.filters,
                relationsDetails: relationsDetails
            )
            
            self.handleCreatedObjectId(objectId, type: type)
        }
    }
}

// MARK: - Routing
extension EditorSetViewModel {

    func showRelationValueEditingView(key: String) {
        if key == BundledRelationKey.setOf.rawValue {
            showSetOfTypeSelection()
            
            return
        }

        AnytypeAnalytics.instance().logChangeRelationValue(type: .set)

        router?.showRelationValueEditingView(key: key)
    }
    
    func showRelationValueEditingView(
        objectId: BlockId,
        relation: Relation
    ) {
        AnytypeAnalytics.instance().logChangeRelationValue(type: .set)
        
        router?.showRelationValueEditingView(
            objectId: objectId,
            relation: relation
        )
    }
    
    func showViewPicker() {
        router?.showViewPicker(
            setDocument: setDocument,
            dataviewService: dataviewService)
        { [weak self] activeView in
            self?.showViewTypes(with: activeView)
        }
    }
    
    func showSetSettings() {
        router?.showSetSettings { [weak self] setting in
            guard let self else { return }
            switch setting {
            case .view:
                self.showViewTypes(with: self.activeView)
            case .settings:
                self.showViewSettings()
            case .sort:
                self.showSorts()
            case .filter:
                self.showFilters()
            }
        }
    }
    
    func showViewTypes(with activeView: DataviewView?) {
        router?.showViewTypes(
            dataView: setDocument.dataView,
            activeView: activeView,
            source: details?.setOf ?? [],
            dataviewService: dataviewService
        )
    }

    func showViewSettings() {
        router?.showViewSettings(
            setDocument: setDocument,
            dataviewService: dataviewService
        )
    }
    
    func showSorts() {
        router?.showSorts(
            setDocument: setDocument,
            dataviewService: dataviewService
        )
    }
    
    func showFilters() {
        router?.showFilters(
            setDocument: setDocument,
            dataviewService: dataviewService
        )
    }
    
    func showObjectSettings() {
        router?.showSettings()
    }
    
    func objectOrderUpdate(with groupObjectIds: [GroupObjectIds]) {
        Task { [weak self] in
            guard let self else { return }
            try await self.dataviewService.objectOrderUpdate(
                viewId: self.activeView.id,
                groupObjectIds: groupObjectIds
            )
        }
    }
    
    func showKanbanColumnSettings(for groupId: String) {
        let groupOrder = setDocument.dataView.groupOrders.first { [weak self] in $0.viewID == self?.activeView.id }
        let viewGroup = groupOrder?.viewGroups.first { $0.groupID == groupId }
        let selectedColor = MiddlewareColor(rawValue: viewGroup?.backgroundColor ?? "")?.backgroundColor
        router?.showKanbanColumnSettings(
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
    
    func showIconPicker() {
        router?.showIconPicker()
    }
    
    func showSetOfTypeSelection() {
        router?.showQueries(selectedObjectId: setDocument.details?.setOf.first) { [weak self] typeObjectId in
            guard let self else { return }
            Task { @MainActor in
                try? await self.objectActionsService.setSource(objectId: self.objectId, source: [typeObjectId])
            }
        }
    }
    
    private func dataviewGroupOrderUpdate(groupId: String, hidden: Bool, backgroundColor: BlockBackgroundColor?) {
        let updatedGroupOrder = updatedGroupOrder(groupId: groupId, hidden: hidden, backgroundColor: backgroundColor)
        Task { [weak self] in
            guard let self else { return }
            try await self.dataviewService.groupOrderUpdate(
                viewId: self.activeView.id,
                groupOrder: updatedGroupOrder
            )
        }
    }
    
    private func updatedGroupOrder(groupId: String, hidden: Bool, backgroundColor: BlockBackgroundColor?) -> DataviewGroupOrder {
        let groupOrder = setDocument.dataView.groupOrders.first { [weak self] in $0.viewID == self?.activeView.id } ??
        DataviewGroupOrder.create(viewID: activeView.id)
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
    
    private func handleCreatedObjectId(_ objectId: String, type: String) {
        if type == ObjectTypeId.BundledTypeId.note.rawValue {
            openObject(pageId: objectId, type: .page)
        } else {
            router?.showCreateObject(pageId: objectId)
        }
    }
    
    private func openObject(pageId: BlockId, type: EditorViewType) {
        let screenData = EditorScreenData(pageId: pageId, type: type)
        router?.showPage(data: screenData)
    }
    
    private func createBookmarkObject() {
        router?.showCreateBookmarkObject()
    }
}

extension EditorSetViewModel {
    static let emptyPreview = EditorSetViewModel(
        setDocument: SetDocument(
            document: BaseDocument(objectId: "objectId"),
            blockId: nil,
            targetObjectID: nil,
            relationDetailsStorage: DI.preview.serviceLocator.relationDetailsStorage()
        ),
        subscriptionService: DI.preview.serviceLocator.subscriptionService(),
        dataviewService: DataviewService(objectId: "objectId", blockId: "blockId", prefilledFieldsBuilder: SetPrefilledFieldsBuilder()),
        searchService: DI.preview.serviceLocator.searchService(),
        detailsService: DetailsService(objectId: "objectId", service: ObjectActionsService()),
        objectActionsService: DI.preview.serviceLocator.objectActionsService(),
        textService: TextService(),
        groupsSubscriptionsHandler: DI.preview.serviceLocator.groupsSubscriptionsHandler(),
        setSubscriptionDataBuilder: SetSubscriptionDataBuilder(accountManager: DI.preview.serviceLocator.accountManager())
    )
}
