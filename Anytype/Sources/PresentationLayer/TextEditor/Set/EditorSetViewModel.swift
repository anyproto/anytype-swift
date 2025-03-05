import Combine
import Services
import AnytypeCore
import SwiftUI
import OrderedCollections


@MainActor
final class EditorSetViewModel: ObservableObject {
    let headerModel: ObjectHeaderViewModel
    let showHeader: Bool
    
    @Published var titleString: String
    @Published var descriptionString: String
    @Published var loadingDocument = true
    @Published var featuredRelations = [Relation]()
    @Published var dismiss = false
    @Published var showUpdateAlert = false
    @Published var showCommonOpenError = false
    @Published var relationsCount = 0
    @Published var templatesCount = 0

    
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    
    private var externalActiveViewId: String?
    
    private var recordsDict: OrderedDictionary<String, [ObjectDetails]> = [:]
    private var groups: [DataviewGroup] = []
    
    @MainActor
    lazy var headerSettingsViewModel = SetHeaderSettingsViewModel(
        setDocument: setDocument,
        onViewTap: { [weak self] in self?.showViewPicker() },
        onAITap: { [weak self] in self?.showAITool() },
        onSettingsTap: { [weak self] in self?.showSetSettings() } ,
        onCreateTap: { [weak self] in self?.createObject() },
        onSecondaryCreateTap: { [weak self] in self?.onSecondaryCreateTap() }
    )
    @Published var configurationsDict: OrderedDictionary<String, [SetContentViewItemConfiguration]> = [:]
    @Published var pagitationDataDict: OrderedDictionary<String, EditorSetPaginationData> = [:]
    
    @Published var syncStatusData = SyncStatusData(status: .offline, networkId: "", isHidden: true)
    
    var isUpdating = false

    var objectId: String {
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
    
    var isGroupBackgroundColors: Bool {
        activeView.groupBackgroundColors
    }
    
    var contentViewType: SetContentViewType {
        activeView.type.setContentViewType
    }
    
    var details: ObjectDetails? {
        setDocument.details
    }
    
    var showDescription: Bool {
        guard let details = setDocument.details else { return false }
        let isFeatured = details.featuredRelations.contains { $0 == BundledRelationKey.description.rawValue }
        return isFeatured
    }
    
    var showObjectTypeTemplates: Bool {
        guard let details = setDocument.details else { return false }
        
        let isSupportedLayout = details.recommendedLayoutValue.isEditorLayout
        let isTemplate = details.uniqueKeyValue == ObjectTypeUniqueKey.template
        return isSupportedLayout && !isTemplate
    }
    
    var hasTargetObjectId: Bool {
        setDocument.inlineParameters?.targetObjectID != nil
    }
    
    var showEmptyState: Bool {
        (isEmptyQuery && !setDocument.isCollection()) ||
        (recordsDict.values.first { $0.isNotEmpty } == nil && setDocument.activeViewFilters.isEmpty)
    }
    
    var emptyStateMode: EditorSetEmptyMode {
        isEmptyQuery && !setDocument.isCollection() ?
            .emptyQuery(canChange: setDocument.setPermissions.canChangeQuery) :
            .emptyList(canCreate: setDocument.setPermissions.canCreateObject)
    }
    
    var subscriptionId: String {
        setSubscriptionDataBuilder.subscriptionId
    }
    
    private var isEmptyQuery: Bool {
        setDocument.details?.filteredSetOf.isEmpty ?? true
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
    
    func contextMenuItems(for relation: Relation) -> [RelationValueViewModel.MenuItem] {
        guard relation.key == BundledRelationKey.type.rawValue else {
            return []
        }
        return .builder {
            if setDocument.setPermissions.canTurnSetIntoCollection {
                RelationValueViewModel.MenuItem(
                    title: Loc.Set.TypeRelation.ContextMenu.turnIntoCollection,
                    action: { [weak self] in
                        self?.turnSetIntoCollection()
                    }
                )
            }
            if setDocument.setPermissions.canChangeQuery {
                RelationValueViewModel.MenuItem(
                    title: isEmptyQuery ? Loc.Set.SourceType.selectQuery : Loc.Set.TypeRelation.ContextMenu.changeQuery,
                    action: { [weak self] in
                        self?.showSetOfTypeSelection()
                    }
                )
            }
        }
    }
    
    // MARK: - Object type methods
    
    func onObjectTypeLayoutTap() {
        output?.onObjectTypeLayoutTap(LayoutPickerData(
            objectId: setDocument.objectId,
            spaceId: setDocument.spaceId,
            analyticsType: setDocument.details?.analyticsType ?? .custom
        ))
    }
    
    func onObjectTypeFieldsTap() {
        output?.onObjectTypeFieldsTap(document: setDocument)
    }
    
    func onObjectTypeTemplatesTap() {
        output?.onObjectTypeTemplatesTap(document: setDocument)
    }
    
    private func groupFirstOptionBackgroundColor(for groupId: String) -> BlockBackgroundColor {
        guard let backgroundColor = groups.first(where: { $0.id == groupId })?.backgroundColor(document: setDocument.document) else {
            return BlockBackgroundColor.gray
        }
        return backgroundColor
    }
    
    let setDocument: any SetDocumentProtocol
    let paginationHelper = EditorSetPaginationHelper()

    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    @Injected(\.templatesSubscription)
    private var templatesSubscription: any TemplatesSubscriptionServiceProtocol
    @Injected(\.dataviewService)
    private var dataviewService: any DataviewServiceProtocol
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @Injected(\.detailsService)
    private var detailsService: any DetailsServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.relationsService)
    private var relationsService: any RelationsServiceProtocol
    @Injected(\.textServiceHandler)
    private var textServiceHandler: any TextServiceProtocol
    @Injected(\.groupsSubscriptionsHandler)
    private var groupsSubscriptionsHandler: any GroupsSubscriptionsHandlerProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.setSubscriptionDataBuilder)
    private var setSubscriptionDataBuilder: any SetSubscriptionDataBuilderProtocol
    @Injected(\.setGroupSubscriptionDataBuilder)
    private var setGroupSubscriptionDataBuilder: any SetGroupSubscriptionDataBuilderProtocol
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: any RelationDetailsStorageProtocol
    private let documentsProvider: any DocumentsProviderProtocol = Container.shared.documentsProvider()
    
    private var subscriptions = [AnyCancellable]()
    private var subscriptionStorages = [String: any SubscriptionStorageProtocol]()
    private var titleSubscription: AnyCancellable?
    private var descriptionSubscription: AnyCancellable?
    private weak var output: (any EditorSetModuleOutput)?

    init(data: EditorListObject, showHeader: Bool, output: (any EditorSetModuleOutput)?) {
        self.setDocument = documentsProvider.setDocument(
            objectId: data.objectId,
            spaceId: data.spaceId,
            mode: data.mode,
            inlineParameters: data.inline
        )
        self.headerModel = ObjectHeaderViewModel(
            document: setDocument.document,
            targetObjectId: setDocument.targetObjectId,
            configuration: EditorPageViewModelConfiguration(
                blockId: nil,
                usecase: data.usecase
            ),
            output: output
        )
        self.externalActiveViewId = data.activeViewId
        self.titleString = setDocument.details?.pageCellTitle ?? ""
        self.descriptionString = setDocument.details?.description ?? ""
        
        self.showHeader = showHeader
        self.output = output
        self.setup()
    }
    
    private func setup() {
        
        headerModel.onIconPickerTap = { [weak self] document in
            self?.output?.showIconPicker(document: document)
        }
        
        syncStatusData = SyncStatusData(status: .offline, networkId: accountManager.account.info.networkId, isHidden: false)
        
        setDocument.setUpdatePublisher.sink { [weak self] update in
            Task { [weak self] in
                await self?.onDataChange(update)
            }
        }.store(in: &subscriptions)
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await setDocument.open()
                updateWithExternalActiveViewIdIfNeeded()
                loadingDocument = false
                await onDataviewUpdate()
                logModuleScreen()
            } catch ObjectOpenError.anytypeNeedsUpgrade {
                showUpdateAlert = true
            } catch {
                showCommonOpenError = true
            }
        }
    }
    
    func updateWithExternalActiveViewIdIfNeeded() {
        guard let externalActiveViewId else { return }
        setDocument.updateActiveViewIdAndReload(externalActiveViewId)
    }
    
    func logModuleScreen() {
        let type = activeView.type.analyticStringValue
        if self.setDocument.isCollection() {
            AnytypeAnalytics.instance().logScreenCollection(with: type, spaceId: setDocument.spaceId)
        } else {
            AnytypeAnalytics.instance().logScreenSet(with: type, spaceId: setDocument.spaceId)
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
            output?.showFailureToast(message: Loc.Set.SourceType.Cancel.Toast.title)
        } else {
            showRelationValueEditingView(key: relation.key)
        }
    }
    
    func startSubscriptions() async {
        guard FeatureFlags.openTypeAsSet else { return }
        
        async let templatesSub: () = subscribeOnTemplates()
        async let relationsSub: () = subscribeOnRelations()
    
        (_, _) = await (templatesSub, relationsSub)
    }
    
    private func subscribeOnTemplates() async {
        let publisher = await templatesSubscription.startSubscription(objectType: setDocument.objectId, spaceId: setDocument.spaceId, update: nil)
        for await templates in publisher.values {
            templatesCount = templates.count
        }
    }
    
    private func subscribeOnRelations() async {
        for await relations in setDocument.document.parsedRelationsPublisherForType.values {
            let conflictingKeys = (try? await relationsService
                .getConflictRelationsForType(typeId: setDocument.objectId, spaceId: setDocument.spaceId)) ?? []
            let conflictingRelations = relationDetailsStorage
                .relationsDetails(ids: conflictingKeys, spaceId: setDocument.spaceId)
                .filter { !$0.isHidden && !$0.isDeleted }

            self.relationsCount = relations.installed.count + conflictingRelations.count
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
                status: status.syncStatus,
                networkId: accountManager.account.info.networkId,
                isHidden: false
            )
        }
    }
    
    private func onDataviewUpdate(clearState shouldClearState: Bool = false) async {
        // Show for empty state
        featuredRelations = setDocument.featuredRelationsForEditor
        
        guard setDocument.blockDataview.isNotNil else { return }
        setDocument.blockDataview.flatMap { dataView in
            anytypeAssert(dataView.views.isNotEmpty, "Empty views in dataview: \(dataView)")
        }
        
        isUpdating = true
        
        if shouldClearState {
            await clearState()
        }
        setupTitle()
        setupDescription()
        await startSubscriptionIfNeeded()
        updateConfigurations(with: Array(recordsDict.keys))

        isUpdating = false
    }
    
    private func setupTitle() {
        if let details = setDocument.details {
            titleString = details.pageCellTitle

            titleSubscription = $titleString.sink { [weak self] newValue in
                self?.updateTextFieldData(newValue: newValue, blockId: CustomRelationKey.title.rawValue) {
                    self?.descriptionString = $0
                }
            }
        }
    }
    
    private func setupDescription() {
        if let details = setDocument.details {
            descriptionString = details.description

            descriptionSubscription = $descriptionString.sink { [weak self] newValue in
                self?.updateTextFieldData(newValue: newValue, blockId: BundledRelationKey.description.rawValue) {
                    self?.titleString = $0
                }
            }
        }
    }
    
    private func updateTextFieldData(newValue: String, blockId: String, updateValue: @escaping (String) -> ()) {
        guard !isUpdating else { return }

        // Return button tapped on keyboard. Waiting for iOS 15 support
        if newValue.contains(where: \.isNewline) {
            isUpdating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                updateValue(newValue.trimmingCharacters(in: .newlines))
            }
            UIApplication.shared.hideKeyboard()
            return
        }

        Task { @MainActor in
            try? await textServiceHandler.setText(
                contextId: setDocument.inlineParameters?.targetObjectID ?? objectId,
                blockId: blockId,
                middlewareString: .init(text: newValue, marks: .init())
            )
            
            isUpdating = false
        }
    }

    
    // MARK: - Groups Subscriptions
    
    private func setupGroupsSubscription(forceUpdate: Bool) async throws {
        let data = setGroupSubscriptionDataBuilder.groupsData(setDocument)
        let hasGroupDiff = await groupsSubscriptionsHandler.hasGroupsSubscriptionDataDiff(with: data)
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
        for group in sortedVisibleGroups() {
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
            numberOfRowsPerPage = userDefaults.rowsPerPageInGroupedSet * max(pagitationData.selectedPage, 1)
            currentPage = 1
        } else {
            numberOfRowsPerPage = userDefaults.rowsPerPageInSet
            currentPage = max(pagitationData.selectedPage, 1)
        }
        
        guard setDocument.canStartSubscription() else { return }
        
        let data = setSubscriptionDataBuilder.set(
            SetSubscriptionData(
                identifier: subscriptionId,
                document: setDocument,
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
            await self?.updateData(with: subscriptionId, numberOfRowsPerPage: numberOfRowsPerPage, state: state)
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
                    viewRelationValueIsLocked: !setDocument.setPermissions.canEditRelationValuesInView, 
                    canEditIcon: setDocument.setPermissions.canEditSetObjectIcon,
                    storage: subscription.detailsStorage,
                    spaceId: setDocument.spaceId,
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
        output?.showSetObjectCreationSettings(
            document: setDocument,
            viewId: activeView.id,
            onTemplateSelection: { [weak self] setting in
                self?.createObject(setting: setting)
            }
        )
    }

    func onEmptyStateButtonTap() {
        switch emptyStateMode {
        case .emptyQuery:
            showSetOfTypeSelection()
        case .emptyList:
            createObject()
        }
    }
    
    private func createObject(setting: ObjectCreationSetting? = nil) {
        output?.showCreateObject(document: setDocument, setting: setting)
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
    
    func showSyncStatusInfo() {
        output?.showSyncStatusInfo(spaceId: setDocument.spaceId)
    }

    func showRelationValueEditingView(key: String) {
        if key == BundledRelationKey.setOf.rawValue {
            showSetOfTypeSelection()
            return
        }
        
        let relation = setDocument.parsedRelations.installed.first { $0.key == key }
        guard let relation = relation else { return }
        guard let objectDetails = setDocument.details else {
            anytypeAssertionFailure("Set document doesn't contains details")
            return
        }
        
        output?.showRelationValueEditingView(objectDetails: objectDetails, relation: relation)
    }
    
    func showRelationValueEditingView(
        objectId: String,
        relation: Relation
    ) {
        guard let detailsStorage = defaultSubscriptionDetailsStorage() else { return }
        guard let objectDetails = detailsStorage.get(id: objectId) else {
            anytypeAssertionFailure("Details not found")
            return
        }
        
        output?.showRelationValueEditingView(
            objectDetails: objectDetails,
            relation: relation
        )
    }
    
    func showViewPicker() {
        guard let detailsStorage = defaultSubscriptionDetailsStorage() else { return }
        output?.showSetViewPicker(document: setDocument, subscriptionDetailsStorage: detailsStorage)
    }
    
    func showAITool() {
        guard let objectDetails = recordsDict[setSubscriptionDataBuilder.subscriptionId],
              objectDetails.isNotEmpty else { return }
        let objectIds = objectDetails.map(\.id)
        output?.showAITool(objectIds: objectIds)
    }
    
    func showSetSettings() {
        guard let detailsStorage = defaultSubscriptionDetailsStorage() else { return }
        output?.showSetViewSettings(document: setDocument, subscriptionDetailsStorage: detailsStorage)
    }
    
    func showObjectSettings() {
        output?.showSettings()
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
        output?.showKanbanColumnSettings(
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
        output?.showIconPicker(document: setDocument.document)
    }
    
    func showSetOfTypeSelection() {
        guard setDocument.setPermissions.canChangeQuery else { return }
        output?.showQueries(document: setDocument, selectedObjectId: setDocument.details?.filteredSetOf.first) { [weak self] typeObjectId in
            guard let self else { return }
            Task { @MainActor in
                try? await self.objectActionsService.setSource(objectId: self.objectId, source: [typeObjectId])
            }
            AnytypeAnalytics.instance().logSetSelectQuery()
        }
    }
    
    private func turnSetIntoCollection() {
        guard setDocument.setPermissions.canTurnSetIntoCollection else { return }
        Task { @MainActor in
            try await objectActionsService.setObjectCollectionType(objectId: objectId)
            output?.replaceEditorScreen(data: .list(EditorListObject(objectId: objectId, spaceId: setDocument.spaceId)))
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
        output?.showEditorScreen(data: details.screenData())
    }
}

extension EditorSetViewModel {
    static let emptyPreview = EditorSetViewModel(
        data: EditorListObject(objectId: "", spaceId: ""), 
        showHeader: true,
        output: nil
    )
}
