import Combine
import Services
import AnytypeCore
import SwiftUI
import OrderedCollections

@MainActor
final class EditorSetViewModel: ObservableObject {
    let headerModel: ObjectHeaderViewModel
    
    @Published var titleString: String
    @Published var loadingDocument = true
    @Published var featuredRelations = [Relation]()
    @Published var dismiss = false
    @Published var showUpdateAlert = false
    @Published var showCommonOpenError = false
    
    private var recordsDict: OrderedDictionary<String, [ObjectDetails]> = [:]
    private var groups: [DataviewGroup] = []
    
    @MainActor
    lazy var headerSettingsViewModel = SetHeaderSettingsViewModel(
        setDocument: setDocument,
        onViewTap: { [weak self] in self?.showViewPicker() } ,
        onSettingsTap: { [weak self] in self?.showSetSettings() } ,
        onCreateTap: { [weak self] in self?.createObject() },
        onSecondaryCreateTap: { [weak self] in self?.onSecondaryCreateTap() }
    )
    @Published var configurationsDict: OrderedDictionary<String, [SetContentViewItemConfiguration]> = [:]
    @Published var pagitationDataDict: OrderedDictionary<String, EditorSetPaginationData> = [:]
    
    @Published var syncStatusData: SyncStatusData
    
    var isUpdating = false

    var objectId: Services.BlockId {
        setDocument.objectId
    }
    
    var activeView: DataviewView {
        setDocument.activeView
    }
    
    var isEmptyViews: Bool {
        setDocument.dataView.views.isEmpty
    }
    
    var colums: [RelationDetails] {
        setDocument.sortedRelations(for: setDocument.activeView.id)
            .filter { $0.option.isVisible }.map(\.relationDetails)
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
        setDocument.inlineParameters?.targetObjectID != nil
    }
    
    var isEmptyQuery: Bool {
        setDocument.details?.setOf.first { $0.isNotEmpty } == nil
    }
    
    var showEmptyState: Bool {
        (isEmptyQuery && !setDocument.isCollection()) ||
        (setDocument.isCollection() && recordsDict.values.first { $0.isNotEmpty } == nil && setDocument.activeViewFilters.isEmpty)
    }
    
    var subscriptionId: String {
        setSubscriptionDataBuilder.subscriptionId
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
        return group.header(with: activeView.groupRelationKey, document: setDocument.document)
    }
    
    func contextMenuItems(for relation: Relation) -> [RelationValueView.MenuItem] {
        guard !setDocument.isCollection(), relation.key == BundledRelationKey.type.rawValue else {
            return []
        }
        return [
            RelationValueView.MenuItem(
                title: Loc.Set.TypeRelation.ContextMenu.turnIntoCollection,
                action: turnSetIntoCollection
            ),
            RelationValueView.MenuItem(
                title: isEmptyQuery ?
                Loc.Set.SourceType.selectQuery : Loc.Set.TypeRelation.ContextMenu.changeQuery,
                action: showSetOfTypeSelection
            )
        ]
    }
    
    private func groupFirstOptionBackgroundColor(for groupId: String) -> BlockBackgroundColor {
        guard let backgroundColor = groups.first(where: { $0.id == groupId })?.backgroundColor(document: setDocument.document) else {
            return BlockBackgroundColor.gray
        }
        return backgroundColor
    }
    
    let setDocument: SetDocumentProtocol
    let paginationHelper = EditorSetPaginationHelper()
    
    private var router: EditorSetRouterProtocol?
    private let subscriptionStorageProvider: SubscriptionStorageProviderProtocol
    private let dataviewService: DataviewServiceProtocol
    private let searchService: SearchServiceProtocol
    private let detailsService: DetailsServiceProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    private let textServiceHandler: TextServiceProtocol
    private let groupsSubscriptionsHandler: GroupsSubscriptionsHandlerProtocol
    private let setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol
    private let setGroupSubscriptionDataBuilder: SetGroupSubscriptionDataBuilderProtocol
    private var subscriptions = [AnyCancellable]()
    private var subscriptionStorages = [String: SubscriptionStorageProtocol]()
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private var titleSubscription: AnyCancellable?
    private let output: EditorSetModuleOutput?

    init(
        setDocument: SetDocumentProtocol,
        headerViewModel: ObjectHeaderViewModel,
        subscriptionStorageProvider: SubscriptionStorageProviderProtocol,
        dataviewService: DataviewServiceProtocol,
        searchService: SearchServiceProtocol,
        detailsService: DetailsServiceProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        textServiceHandler: TextServiceProtocol,
        groupsSubscriptionsHandler: GroupsSubscriptionsHandlerProtocol,
        setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol,
        setGroupSubscriptionDataBuilder: SetGroupSubscriptionDataBuilderProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        output: EditorSetModuleOutput?
    ) {
        self.setDocument = setDocument
        self.headerModel = headerViewModel
        self.subscriptionStorageProvider = subscriptionStorageProvider
        self.dataviewService = dataviewService
        self.searchService = searchService
        self.detailsService = detailsService
        self.objectActionsService = objectActionsService
        self.textServiceHandler = textServiceHandler
        self.groupsSubscriptionsHandler = groupsSubscriptionsHandler
        self.setSubscriptionDataBuilder = setSubscriptionDataBuilder
        self.setGroupSubscriptionDataBuilder = setGroupSubscriptionDataBuilder
        self.titleString = setDocument.details?.pageCellTitle ?? ""
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.output = output
        self.syncStatusData = SyncStatusData(status: .unknown, networkId: activeWorkspaceStorage.workspaceInfo.networkId)
    }
    
    func setup(router: EditorSetRouterProtocol) {
        self.router = router
        
        setDocument.setUpdatePublisher.sink { [weak self] update in
            Task { [weak self] in
                await self?.onDataChange(update)
            }
        }.store(in: &subscriptions)
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await self.setDocument.open()
                self.loadingDocument = false
                await self.onDataviewUpdate()
                self.logModuleScreen()
            } catch ObjectOpenError.anytypeNeedsUpgrade {
                showUpdateAlert = true
            } catch {
                showCommonOpenError = true
            }
        }
    }
    
    func logModuleScreen() {
        if self.setDocument.isCollection() {
            AnytypeAnalytics.instance().logScreenCollection()
        } else {
            AnytypeAnalytics.instance().logScreenSet()
        }
    }
    
    func onAppear() {
        Task {
            await startSubscriptionIfNeeded()
        }
        
    }
    
    func onDisappear() {
        Task {
            await stopAllSubscriptionStorages()
            try await groupsSubscriptionsHandler.stopAllSubscriptions()
        }
    }

    func onRelationTap(relation: Relation) {
        if relation.hasSelectedObjectsRelationType {
            router?.showFailureToast(message: Loc.Set.SourceType.Cancel.Toast.title)
        } else {
            showRelationValueEditingView(key: relation.key)
        }
    }

    func startSubscriptionIfNeeded(forceUpdate: Bool = false) async {
        guard setDocument.dataView.activeViewId.isNotEmpty else {
            await stopAllSubscriptionStorages()
            return
        }
        
        if activeView.type.hasGroups {
            try? await setupGroupsSubscription(forceUpdate: forceUpdate)
        } else {
            setupPaginationDataIfNeeded(groupId: setSubscriptionDataBuilder.subscriptionId)
            await startSubscriptionIfNeeded(with: setSubscriptionDataBuilder.subscriptionId)
        }
    }
    
    func updateObjectDetails(_ detailsId: String, groupId: String) {
        guard let group = groups.first(where: { $0.id == groupId }),
        let value = group.value else { return }

        Task {
            try await detailsService.updateDetails(
                contextId: detailsId,
                relationKey: activeView.groupRelationKey,
                value: value
            )
        }
    }
    
    func pagitationData(by groupId: String? = nil) -> EditorSetPaginationData {
        let groupId = groupId ?? setSubscriptionDataBuilder.subscriptionId
        return pagitationDataDict[groupId] ?? EditorSetPaginationData.empty
    }
    
    // MARK: - Private
    
    private func onDataChange(_ update: SetDocumentUpdate) async {
        switch update {
        case .dataviewUpdated(clearState: let clearState):
            await onDataviewUpdate(clearState: clearState)
        case .syncStatus(let status):
            syncStatusData = SyncStatusData(
                status: status,
                networkId: activeWorkspaceStorage.workspaceInfo.networkId
            )
        }
    }
    
    private func onDataviewUpdate(clearState shouldClearState: Bool = false) async {
        // Show for empty state
        featuredRelations = setDocument.featuredRelationsForEditor
        
        guard setDocument.dataviews.isNotEmpty else { return }
        anytypeAssert(setDocument.dataviews.count < 2, "\(setDocument.dataviews.count) dataviews in set")
        setDocument.dataviews.first.flatMap { dataView in
            anytypeAssert(dataView.views.isNotEmpty, "Empty views in dataview: \(dataView)")
        }
        
        isUpdating = true
        
        if shouldClearState {
            await clearState()
        }
        setupTitle()
        await startSubscriptionIfNeeded()
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

                Task { @MainActor in
                    try? await self.textServiceHandler.setText(
                        contextId: self.setDocument.inlineParameters?.targetObjectID ?? self.objectId,
                        blockId: RelationKey.title.rawValue,
                        middlewareString: .init(text: newValue, marks: .init())
                    )
                    
                    self.isUpdating = false
                }
            }
        }
    }
    
    // MARK: - Groups Subscriptions
    
    private func setupGroupsSubscription(forceUpdate: Bool) async throws {
        let data = setGroupSubscriptionDataBuilder.groupsData(setDocument)
        let hasGroupDiff = groupsSubscriptionsHandler.hasGroupsSubscriptionDataDiff(with: data)
        if hasGroupDiff {
            try await groupsSubscriptionsHandler.stopAllSubscriptions()
            groups = try await startGroupsSubscription(with: data)
        }

        let groupOrderUpdates = await checkGroupOrderUpdates()
            
        if forceUpdate || groupOrderUpdates || hasGroupDiff {
            await startSubscriptionsByGroups()
        }
    }
    
    private func checkGroupOrderUpdates() async -> Bool {
        let groupOrder = setDocument.dataView.groupOrders.first { [weak self] in $0.viewID == self?.activeView.id }
        let visibleViewGroups = groupOrder?.viewGroups.filter { !$0.hidden }
        let newVisible = visibleViewGroups?.first { [weak self] in self?.recordsDict[$0.groupID] == nil }
        
        let hiddenViewGroups = groupOrder?.viewGroups.filter { $0.hidden } ?? []
        var hasNewHidden = false
        for group in hiddenViewGroups {
            if recordsDict[group.groupID] != nil {
                hasNewHidden = true
                recordsDict[group.groupID] = nil
                configurationsDict[group.groupID] = nil
                try? await subscriptionStorages[group.groupID]?.stopSubscription()
            }
        }
        
        return newVisible != nil || hasNewHidden
    }
    
    private func startGroupsSubscription(with data: GroupsSubscriptionData) async throws -> [DataviewGroup] {
        try await groupsSubscriptionsHandler.startGroupsSubscription(data: data) { [weak self] group, remove in
            guard let self else { return }
            if remove {
                self.groups = self.groups.filter { $0 != group }
            } else {
                self.groups.append(group)
            }
            await startSubscriptionsByGroups()
        }
    }
    
    private func startSubscriptionsByGroups() async {
        await sortedVisibleGroups().asyncForEach { group in
            let groupFilter = group.filter(with: self.activeView.groupRelationKey)
            let subscriptionId = group.id
            setupPaginationDataIfNeeded(groupId: group.id)
            await startSubscriptionIfNeeded(with: subscriptionId, groupFilter: groupFilter)
        }
    }
    
    private func setupPaginationDataIfNeeded(groupId: String) {
        guard pagitationDataDict[groupId] == nil else { return }
        pagitationDataDict[groupId] = EditorSetPaginationData.empty
    }
    
    private func startSubscriptionIfNeeded(with subscriptionId: String, groupFilter: DataviewFilter? = nil) async {
        let pagitationData = pagitationData(by: subscriptionId)
        let currentPage: Int
        let numberOfRowsPerPage: Int
        if activeView.type.hasGroups {
            numberOfRowsPerPage = UserDefaultsConfig.rowsPerPageInGroupedSet * max(pagitationData.selectedPage, 1)
            currentPage = 1
        } else {
            numberOfRowsPerPage = UserDefaultsConfig.rowsPerPageInSet
            currentPage = max(pagitationData.selectedPage, 1)
        }
        
        guard setDocument.canStartSubscription() else { return }
        
        let data = setSubscriptionDataBuilder.set(
            .init(
                identifier: subscriptionId,
                source: setDocument.details?.setOf,
                view: activeView,
                groupFilter: groupFilter,
                currentPage: currentPage, // show first page for empty request
                numberOfRowsPerPage: numberOfRowsPerPage,
                collectionId: setDocument.isCollection() ? objectId : nil,
                objectOrderIds: setDocument.objectOrderIds(for: subscriptionId)
            )
        )
        
        let subscription = subscriptionStorages[data.identifier] ?? subscriptionStorageProvider.createSubscriptionStorage(subId: data.identifier)
        subscriptionStorages[data.identifier] = subscription

        try? await subscription.startOrUpdateSubscription(data: data) { [weak self] state in
            guard let self else { return }
            updateData(with: subscriptionId, numberOfRowsPerPage: numberOfRowsPerPage, state: state)
        }
    }

    private func updateData(with groupId: String, numberOfRowsPerPage: Int, state: SubscriptionStorageState) {
        let pagesCount = numberOfRowsPerPage > 0 ? Int(ceil(Float(state.total) / Float(numberOfRowsPerPage))) : 0
        updatePageCount(pagesCount, groupId: groupId, ignorePageLimit: activeView.type.hasGroups)
        recordsDict[groupId] = state.items
        updateConfigurations(with: [groupId])
    }
    
    private func stopAllSubscriptionStorages() async {
        await subscriptionStorages.values.asyncForEach { try? await $0.stopSubscription() }
    }
    
    private func updateConfigurations(with groupIds: [String]) {
        var tempConfigurationsDict = configurationsDict
        for groupId in groupIds {
            guard let subscription = subscriptionStorages[groupId] else {
                anytypeAssertionFailure("Subscription not started for group")
                continue
            }
            if let records = sortedRecords(with: groupId) {
                let configurations = setDocument.dataBuilder.itemData(
                    records,
                    dataView: setDocument.dataView,
                    activeView: activeView,
                    isObjectLocked: setDocument.isObjectLocked,
                    storage: subscription.detailsStorage,
                    spaceId: setDocument.spaceId,
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
        let sortedViewGroupsIds = sortedViewGroups().map(\.groupID)
        guard sortedViewGroupsIds.isNotEmpty else { return dict }
        
        let groupIds = Array(dict.keys).reorderedStable(by: sortedViewGroupsIds, transform: { $0 })
        
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
        let hiddenSortedViewGroupsIds = sortedViewGroups.filter { $0.hidden }.map(\.groupID)
        let visibleGroups = groups.filter { !hiddenSortedViewGroupsIds.contains($0.id) }
        
        return visibleGroups.reordered(
            by: sortedViewGroups.map(\.groupID),
            transform: { $0.id }
        )
    }
    
    private func sortedRecords(with groupId: String) -> [ObjectDetails]? {
        let objectOrderIds = setDocument.objectOrderIds(for: groupId)
        guard objectOrderIds.isNotEmpty,
              let records = recordsDict[groupId] else {
            return recordsDict[groupId]
        }
        return records.reorderedStable(by: objectOrderIds, transform: { $0.id })
    }
        
    private func updateDetailsIfNeeded(_ details: ObjectDetails) {
        guard details.layoutValue == .todo else { return }
        Task {
            try await detailsService.updateBundledDetails(
                contextID: details.id,
                bundledDetails: [.done(!details.isDone)]
            )
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
    }
    
    @MainActor
    private func itemTapped(_ details: ObjectDetails) {
        openObject(details: details)
    }
    
    private func clearState() async {
        recordsDict = [:]
        configurationsDict = [:]
        pagitationDataDict = [:]
        groups = []
        await stopAllSubscriptionStorages()
        try? await groupsSubscriptionsHandler.stopAllSubscriptions()
    }
    
    @MainActor
    func onSecondaryCreateTap() {
        router?.showSetObjectCreationSettings(
            setDocument: setDocument,
            viewId: activeView.id,
            onTemplateSelection: { [weak self] setting in
                self?.createObject(setting: setting)
            }
        )
    }

    func onEmptyStateButtonTap() {
        if setDocument.isCollection() {
            createObject()
        } else {
            showSetOfTypeSelection()
        }
    }
    
    private func createObject(setting: ObjectCreationSetting? = nil) {
        router?.showCreateObject(setting: setting)
    }

    private func defaultSubscriptionDetailsStorage(file: StaticString = #file, function: String = #function, line: UInt = #line) -> ObjectDetailsStorage? {
        let subscription = subscriptionStorages.values.first
        if subscription.isNil {
            anytypeAssertionFailure("Try map without storage", file: file, function: function, line: line)
        }
        return subscription?.detailsStorage
    }
}

// MARK: - Routing
extension EditorSetViewModel {

    func showRelationValueEditingView(key: String) {
        if key == BundledRelationKey.setOf.rawValue {
            showSetOfTypeSelection()
            return
        }

        router?.showRelationValueEditingView(key: key)
    }
    
    func showRelationValueEditingView(
        objectId: BlockId,
        relation: Relation
    ) {
        guard let detailsStorage = defaultSubscriptionDetailsStorage() else { return }
        guard let objectDetails = detailsStorage.get(id: objectId) else {
            anytypeAssertionFailure("Details not found")
            return
        }
        
        router?.showRelationValueEditingView(
            objectDetails: objectDetails,
            relation: relation
        )
    }
    
    func showViewPicker() {
        guard let detailsStorage = defaultSubscriptionDetailsStorage() else { return }
        router?.showViewPicker(subscriptionDetailsStorage: detailsStorage)
    }
    
    func showSetSettings() {
        guard let detailsStorage = defaultSubscriptionDetailsStorage() else { return }
        router?.showSetSettings(subscriptionDetailsStorage: detailsStorage)
    }
    
    func showObjectSettings() {
        router?.showSettings { [weak self] action in
            switch action {
            case .cover(let objectCoverPickerAction):
                self?.headerModel.handleCoverAction(action: objectCoverPickerAction)
            case .icon(let objectIconPickerAction):
                self?.headerModel.handleIconAction(action: objectIconPickerAction)
            }
        }
    }
    
    func objectOrderUpdate(with groupObjectIds: [GroupObjectIds]) {
        Task { [weak self] in
            guard let self else { return }
            try await self.dataviewService.objectOrderUpdate(
                objectId: setDocument.objectId,
                blockId: setDocument.blockId,
                order: groupObjectIds.map { DataviewObjectOrder(viewID: self.activeView.id, groupID: $0.groupId, objectIds: $0.objectIds) }
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
        router?.showIconPicker(document: setDocument) { [weak self] action in
            self?.headerModel.handleIconAction(action: action)
        }
    }
    
    func showSetOfTypeSelection() {
        router?.showQueries(selectedObjectId: setDocument.details?.setOf.first) { [weak self] typeObjectId in
            guard let self else { return }
            Task { @MainActor in
                try? await self.objectActionsService.setSource(objectId: self.objectId, source: [typeObjectId])
            }
            AnytypeAnalytics.instance().logSetSelectQuery()
        }
    }
    
    private func turnSetIntoCollection() {
        Task { @MainActor in
            try await objectActionsService.setObjectCollectionType(objectId: objectId)
            try await setDocument.close()
            output?.replaceEditorScreen(data: .set(EditorSetObject(objectId: objectId, spaceId: setDocument.spaceId)))
        }
        AnytypeAnalytics.instance().logSetTurnIntoCollection()
    }
    
    private func dataviewGroupOrderUpdate(groupId: String, hidden: Bool, backgroundColor: BlockBackgroundColor?) {
        let updatedGroupOrder = updatedGroupOrder(groupId: groupId, hidden: hidden, backgroundColor: backgroundColor)
        Task { [weak self] in
            guard let self else { return }
            try await self.dataviewService.groupOrderUpdate(
                objectId: setDocument.objectId,
                blockId: setDocument.blockId,
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
    
    private func openObject(details: ObjectDetails) {
        output?.showEditorScreen(data: details.editorScreenData())
    }
}

extension EditorSetViewModel {
    static let emptyPreview = EditorSetViewModel(
        setDocument: SetDocument(
            document: MockBaseDocument(),
            inlineParameters: nil,
            relationDetailsStorage: DI.preview.serviceLocator.relationDetailsStorage(),
            objectTypeProvider: DI.preview.serviceLocator.objectTypeProvider()
        ),
        headerViewModel: .init(
            document: MockBaseDocument(),
            configuration: .init(
                isOpenedForPreview: false,
                usecase: .editor
            ),
            interactor: DI.preview.serviceLocator.objectHeaderInteractor(objectId: "objectId")
        ),
        subscriptionStorageProvider: DI.preview.serviceLocator.subscriptionStorageProvider(),
        dataviewService: DI.preview.serviceLocator.dataviewService(),
        searchService: DI.preview.serviceLocator.searchService(),
        detailsService: DetailsService(
            objectId: "objectId",
            service: DI.preview.serviceLocator.objectActionsService(),
            fileService: DI.preview.serviceLocator.fileService()
        ),
        objectActionsService: DI.preview.serviceLocator.objectActionsService(),
        textServiceHandler: DI.preview.serviceLocator.textServiceHandler(),
        groupsSubscriptionsHandler: DI.preview.serviceLocator.groupsSubscriptionsHandler(),
        setSubscriptionDataBuilder: SetSubscriptionDataBuilder(activeWorkspaceStorage: DI.preview.serviceLocator.activeWorkspaceStorage()),
        setGroupSubscriptionDataBuilder: SetGroupSubscriptionDataBuilder(),
        objectTypeProvider: DI.preview.serviceLocator.objectTypeProvider(),
        activeWorkspaceStorage: DI.preview.serviceLocator.activeWorkspaceStorage(),
        output: nil
    )
}
