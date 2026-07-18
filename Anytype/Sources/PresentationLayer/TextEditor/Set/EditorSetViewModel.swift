@preconcurrency import Combine
import Services
import AnytypeCore
import SwiftUI
import OrderedCollections
import SwiftProtobuf


@MainActor
final class EditorSetViewModel: ObservableObject {
    let headerModel: ObjectHeaderViewModel
    let showHeader: Bool
    
    @Published var titleString: String
    @Published var descriptionString: String
    @Published var loadingDocument = true
    @Published var featuredRelations = [Property]()
    @Published var dismiss = false
    @Published var showUpdateAlert = false
    @Published var showCommonOpenError = false
    @Published var relationsCount = 0
    @Published var templatesCount = 0

    
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    
    private var externalActiveViewId: String?
    
    private var recordsDict: OrderedDictionary<String, [ObjectDetails]> = [:]
    private var totalsDict: [String: Int] = [:]
    private var groups: [DataviewGroup] = []
    
    @MainActor
    lazy var headerSettingsViewModel = SetHeaderSettingsViewModel(
        setDocument: setDocument,
        output: output as? (any ObjectSettingsCoordinatorOutput),
        onViewTap: { [weak self] in self?.showViewPicker() },
        onSettingsTap: { [weak self] in self?.showSetSettings() } ,
        onCreateTap: { [weak self] in self?.createObject() },
        onSecondaryCreateTap: { [weak self] in self?.onSecondaryCreateTap() }
    )
    @Published var configurationsDict: OrderedDictionary<String, [SetContentViewItemConfiguration]> = [:]
    @Published var pagitationDataDict: OrderedDictionary<String, EditorSetPaginationData> = [:]
    @Published private(set) var boardState: SetKanbanBoardState = .loading
    @Published private(set) var groupOptionDetails: [String: ObjectDetails] = [:]
    
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

    // Cached to avoid re-sorting on every body re-evaluation; diff-guarded.
    @Published private(set) var colums: [PropertyDetails] = []
    // Captured by value so a permission flip refreshes the header deterministically.
    @Published private(set) var canEditRelationValuesInView = false

    private func updateColumns() {
        let newColumns = setDocument.sortedRelations(for: setDocument.activeView.id)
            .filter { $0.option.isVisible }.map(\.relationDetails)
        if newColumns != colums {
            colums = newColumns
        }
        let newCanEditRelationValues = setDocument.setPermissions.canEditRelationValuesInView
        if canEditRelationValuesInView != newCanEditRelationValues {
            canEditRelationValuesInView = newCanEditRelationValues
        }
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
        let isFeatured = details.featuredRelations.contains { $0 == BundledPropertyKey.description.rawValue }
        return isFeatured
    }
    
    var showObjectTypeTemplates: Bool {
        guard let details = setDocument.details else { return false }
        
        let isSupportedLayout = details.recommendedLayoutValue.isEditorLayout
        let isTemplate = details.isTemplateType
        return isSupportedLayout && !isTemplate
    }
    
    var showProperties: Bool {
        guard let details = setDocument.details else { return false }
        
        return !details.isTemplateType
    }
    
    var hasTargetObjectId: Bool {
        setDocument.inlineParameters?.targetObjectID != nil
    }
    
    var showEmptyState: Bool {
        (isEmptyQuery && !setDocument.isCollection()) ||
        // A board with columns is never empty: emptiness is columns.isEmpty, not cards.isEmpty.
        // Collapsing an all-empty board into the generic screen would also hide the columns
        // needed to create the first card.
        (!activeView.type.hasGroups && recordsDict.values.first { $0.isNotEmpty } == nil && setDocument.activeViewFilters.isEmpty)
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
    
    var headerAlignment: HorizontalAlignment {
        setDocument.details?.objectAlignValue.horizontalAlignment ?? .leading
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
        return group.header(checkboxTitle: groupRelationDisplayName, optionDetails: { [weak self] optionId in
            self?.optionDetails(for: optionId)
        })
    }

    func columnCount(for groupId: String) -> Int {
        totalsDict[groupId] ?? 0
    }

    private var groupRelationDisplayName: String {
        let relationDetails = try? propertyDetailsStorage.relationsDetails(key: activeView.groupRelationKey, spaceId: setDocument.spaceId)
        return relationDetails?.name ?? activeView.groupRelationKey.capitalized
    }

    // Live options first (rename/recolor arrive there), then per-column dependency
    // details, then the document storage as a last resort.
    private func optionDetails(for optionId: String) -> ObjectDetails? {
        groupOptionDetails[optionId]
            ?? subscriptionStorages.values.compactMap { $0.detailsStorage.get(id: optionId) }.first
            ?? setDocument.document.detailsStorage.get(id: optionId)
    }
    
    func contextMenuItems(for relation: Property) -> [PropertyValueViewModel.MenuItem] {
        guard relation.key == BundledPropertyKey.type.rawValue else {
            return []
        }
        return .builder {
            if setDocument.setPermissions.canTurnSetIntoCollection {
                PropertyValueViewModel.MenuItem(
                    title: Loc.Set.TypeRelation.ContextMenu.turnIntoCollection,
                    action: { [weak self] in
                        self?.turnSetIntoCollection()
                    }
                )
            }
            if setDocument.setPermissions.canChangeQuery {
                PropertyValueViewModel.MenuItem(
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
    
    func onObjectTypePropertiesTap() {
        output?.onObjectTypePropertiesTap(document: setDocument)
    }
    
    func onObjectTypeTemplatesTap() {
        output?.onObjectTypeTemplatesTap(document: setDocument)
    }
    
    private func groupFirstOptionBackgroundColor(for groupId: String) -> BlockBackgroundColor {
        let group = groups.first { $0.id == groupId }
        guard let backgroundColor = group?.backgroundColor(optionDetails: { [weak self] optionId in
            self?.optionDetails(for: optionId)
        }) else {
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
    @Injected(\.propertiesService)
    private var propertiesService: any PropertiesServiceProtocol
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
    @Injected(\.propertyDetailsStorage)
    private var propertyDetailsStorage: any PropertyDetailsStorageProtocol
    @Injected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    private let documentsProvider: any DocumentsProviderProtocol = Container.shared.documentsProvider()
    
    private var subscriptions = [AnyCancellable]()
    private var subscriptionStorages = [String: any SubscriptionStorageProtocol]()
    private var startSubscriptionsByGroupsTask: Task<Void, Never>?
    private var boardSubscriptionsEpoch = 0
    private var cardIdsWithPendingMove = Set<String>()
    private var titleSubscription: AnyCancellable?
    private var descriptionSubscription: AnyCancellable?
    private var chatPreviews: [ChatMessagePreview] = []
    private let spaceView: SpaceView?
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
        self.titleString = setDocument.details?.setTitle ?? ""
        self.descriptionString = setDocument.details?.description ?? ""
        
        self.showHeader = showHeader
        self.output = output
        
        let spaceViewsStorage = Container.shared.spaceViewsStorage()
        self.spaceView = spaceViewsStorage.spaceView(spaceId: data.spaceId)
        
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

        // Relation renames/format changes arrive via syncPublisher without a dataview event.
        setDocument.syncPublisher.receiveOnMain().sink { [weak self] in
            guard let self else { return }
            updateColumns()
            // Relation format/read-only changes emit no record Amend; refresh cell configs (diff-guarded).
            updateConfigurations(with: Array(recordsDict.keys))
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
        if let details = setDocument.details, details.isObjectType {
            AnytypeAnalytics.instance().logScreenType(objectType: details.analyticsType)
        } else if setDocument.isCollection() {
            let viewType = activeView.type.analyticStringValue
            AnytypeAnalytics.instance().logScreenCollection(with: viewType)
        } else {
            let viewType = activeView.type.analyticStringValue
            AnytypeAnalytics.instance().logScreenSet(with: viewType)
        }
    }
    
    func onAppear() {
        Task {
            await startSubscriptionIfNeeded()
        }
        
    }
    
    func onDisappear() {
        boardSubscriptionsEpoch += 1
        Task {
            await stopAllSubscriptionStorages()
            try await groupsSubscriptionsHandler.stopAllSubscriptions()
        }
    }

    func onRelationTap(relation: Property) {
        if relation.hasSelectedObjectsRelationType {
            output?.showFailureToast(message: Loc.Set.SourceType.Cancel.Toast.title)
        } else {
            showRelationValueEditingView(key: relation.key)
        }
    }
    
    func startSubscriptions() async {
        async let templatesSub: () = subscribeOnTemplates()
        async let relationsSub: () = subscribeOnRelations()
        async let chatPreviewsSub: () = startChatPreviewsSequence()

        (_, _, _) = await (templatesSub, relationsSub, chatPreviewsSub)
    }
    
    private func subscribeOnTemplates() async {
        let publisher = await templatesSubscription.startSubscription(objectType: setDocument.objectId, spaceId: setDocument.spaceId, update: nil)
        for await templates in publisher.values {
            templatesCount = templates.count
        }
    }
    
    private func subscribeOnRelations() async {
        for await properties in setDocument.document.parsedPropertiesPublisherForType.values {
            let conflictingKeys = (try? await propertiesService
                .getConflictPropertiesForType(typeId: setDocument.objectId, spaceId: setDocument.spaceId)) ?? []
            let conflictingRelations = propertyDetailsStorage
                .relationsDetails(ids: conflictingKeys, spaceId: setDocument.spaceId)
                .filter { !$0.isHidden && !$0.isDeleted }

            self.relationsCount = properties.installed.count + conflictingRelations.count
        }
    }

    private func startChatPreviewsSequence() async {
        for await previews in await chatMessagesPreviewsStorage.previewsSequence {
            chatPreviews = previews
            updateConfigurations(with: Array(recordsDict.keys))
        }
    }
 

    func startSubscriptionIfNeeded(forceUpdate: Bool = false) async {
        guard setDocument.dataView.activeViewId.isNotEmpty else {
            await stopAllSubscriptionStorages()
            return
        }
        
        if activeView.type.hasGroups {
            do {
                try await setupGroupsSubscription(forceUpdate: forceUpdate)
                if boardState != .ready {
                    boardState = .ready
                }
            } catch {
                boardState = .error(message: error.localizedDescription)
            }
        } else {
            setupPaginationDataIfNeeded(groupId: setSubscriptionDataBuilder.subscriptionId)
            await startSubscriptionIfNeeded(subscriptionId: setSubscriptionDataBuilder.subscriptionId, groupId: setSubscriptionDataBuilder.subscriptionId)
        }
    }
    
    @discardableResult
    func updateObjectDetails(_ detailsId: String, fromGroupId: String, toGroupId: String) -> Bool {
        let relationKey = activeView.groupRelationKey
        let move = SetKanbanCardMove.compute(
            currentValue: groupRelationValue(for: detailsId, relationKey: relationKey, groupId: fromGroupId),
            sourceGroupValue: groups.first { $0.id == fromGroupId }?.value,
            targetGroupValue: groups.first { $0.id == toGroupId }?.value,
            groupsLoaded: groups.isNotEmpty
        )

        // Reverts rebuild every column, not just the two involved: an earlier optimistic
        // move may have stripped the card from a third column's configurations.
        guard case let .write(value) = move else {
            revertOptimisticCardMoves()
            return false
        }

        // The RMW reads the backend value; a second move of the same card before the
        // first write round-trips would compute against stale data and resurrect tags.
        guard !cardIdsWithPendingMove.contains(detailsId) else {
            revertOptimisticCardMoves()
            return false
        }
        cardIdsWithPendingMove.insert(detailsId)

        Task {
            defer { cardIdsWithPendingMove.remove(detailsId) }
            do {
                try await propertiesService.updateProperty(
                    objectId: detailsId,
                    propertyKey: relationKey,
                    value: value.protobufValue
                )
                logCardMove(relationKey: relationKey, value: value)
            } catch {
                revertOptimisticCardMoves()
                output?.showFailureToast(message: error.localizedDescription)
            }
        }
        return true
    }

    private func logCardMove(relationKey: String, value: SetKanbanCardMoveValue) {
        guard let relationDetails = try? propertyDetailsStorage.relationsDetails(key: relationKey, spaceId: setDocument.spaceId) else { return }
        AnytypeAnalytics.instance().logChangeOrDeleteRelationValue(
            isEmpty: value == .unset || value == .ids([]),
            format: relationDetails.format,
            type: .dataview,
            key: relationDetails.analyticsKey
        )
    }

    private func groupRelationValue(for detailsId: String, relationKey: String, groupId: String) -> [String] {
        let details = subscriptionStorage(for: groupId)?.detailsStorage.get(id: detailsId)
            ?? subscriptionStorages.values.compactMap { $0.detailsStorage.get(id: detailsId) }.first
        return SetKanbanCardMove.stringList(from: details?.values[relationKey])
    }

    private func subscriptionStorage(for groupId: String) -> (any SubscriptionStorageProtocol)? {
        subscriptionStorages[groupId] ?? subscriptionStorages[recordsSubscriptionId(for: groupId)]
    }

    func isGroupFullyLoaded(_ groupId: String) -> Bool {
        SetKanbanReorder.isColumnFullyLoaded(
            loadedCount: recordsDict[groupId]?.count ?? 0,
            totalCount: totalsDict[groupId]
        )
    }

    var canDragCards: Bool {
        activeView.type.hasGroups && setDocument.setPermissions.canMoveCards
    }

    func revertOptimisticCardMoves() {
        updateConfigurations(with: Array(recordsDict.keys))
    }

    func onBoardErrorRetryTap() async {
        boardState = .loading
        await startSubscriptionIfNeeded(forceUpdate: true)
    }
    
    func pagitationData(by groupId: String? = nil) -> EditorSetPaginationData {
        let groupId = groupId ?? setSubscriptionDataBuilder.subscriptionId
        return pagitationDataDict[groupId] ?? EditorSetPaginationData.empty
    }
    
    func onTypeTitleTap() {
        guard let details else { return }
        let mode: ObjectTypeInfoViewMode = details.restrictionsValue.contains(.details) ? .preview : .edit
        
        output?.showTypeInfoEditor(
            info: ObjectTypeInfo(
                singularName: details.name,
                pluralName: details.pluralName,
                icon: details.customIcon,
                color: details.customIconColor,
                mode: mode
            )
        )
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
        updateColumns()
        await startSubscriptionIfNeeded()
        updateConfigurations(with: Array(recordsDict.keys))

        isUpdating = false
    }
    
    private func setupTitle() {
        if let details = setDocument.details {
            titleString = details.setTitle

            // Same-value publishes (e.g. SwiftUI focus/blur) must not reach setText — every
            // write hits the whole-value LWW text register and can clobber a peer edit.
            titleSubscription = $titleString.removeDuplicates().sink { [weak self] newValue in
                self?.updateTextFieldData(newValue: newValue, blockId: CustomRelationKey.title.rawValue) {
                    self?.descriptionString = $0
                }
            }
        }
    }
    
    private func setupDescription() {
        if let details = setDocument.details {
            descriptionString = details.description

            descriptionSubscription = $descriptionString.removeDuplicates().sink { [weak self] newValue in
                self?.updateTextFieldData(newValue: newValue, blockId: BundledPropertyKey.description.rawValue) {
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
            groups = []
            let snapshot = try await startGroupsSubscription(with: data)
            // Group events can race the subscribe RPC; the callback already applied them
            // to `groups`, so merge instead of overwriting with the snapshot.
            let racedGroups = groups.filter { raced in !snapshot.contains { $0.id == raced.id } }
            groups = snapshot + racedGroups
        }

        await startOptionsSubscription()

        let groupOrderUpdates = checkGroupOrderUpdates()

        if forceUpdate || groupOrderUpdates || hasGroupDiff {
            await startSubscriptionsByGroups()
        }
    }

    private func checkGroupOrderUpdates() -> Bool {
        let groupOrder = setDocument.dataView.groupOrders.first { [weak self] in $0.viewID == self?.activeView.id }
        let visibleViewGroups = groupOrder?.viewGroups.filter { !$0.hidden }
        let newVisible = visibleViewGroups?.first { [weak self] in self?.recordsDict[$0.groupID] == nil }

        let hiddenViewGroups = groupOrder?.viewGroups.filter { $0.hidden } ?? []
        let hasNewHidden = hiddenViewGroups.contains { recordsDict[$0.groupID] != nil }

        return newVisible != nil || hasNewHidden
    }

    private func startGroupsSubscription(with data: GroupsSubscriptionData) async throws -> [DataviewGroup] {
        try await groupsSubscriptionsHandler.startGroupsSubscription(data: data) { [weak self] group, remove in
            guard let self else { return }
            let otherGroups = self.groups.filter { $0.id != group.id }
            self.groups = remove ? otherGroups : otherGroups + [group]
            await startSubscriptionsByGroups()
        }
    }

    // Interleaved invocations (a dataview update racing a group add/remove event) can
    // interleave across await points and stop a column the other run just started;
    // serialize FIFO so each run sees settled state. The epoch check keeps a link that
    // was queued before teardown (onDisappear/clearState) from re-subscribing after it.
    private func startSubscriptionsByGroups() async {
        let epoch = boardSubscriptionsEpoch
        let previousTask = startSubscriptionsByGroupsTask
        let task = Task { [weak self] in
            await previousTask?.value
            guard let self, self.boardSubscriptionsEpoch == epoch else { return }
            await self.startSubscriptionsByGroupsSerialized()
        }
        startSubscriptionsByGroupsTask = task
        await task.value
    }

    private func startSubscriptionsByGroupsSerialized() async {
        let visibleGroups = sortedVisibleGroups()
        await stopStaleGroupSubscriptions(activeGroupIds: visibleGroups.map(\.id))
        for group in visibleGroups {
            let groupFilter = group.filter(with: self.activeView.groupRelationKey)
            setupPaginationDataIfNeeded(groupId: group.id)
            await startSubscriptionIfNeeded(subscriptionId: recordsSubscriptionId(for: group.id), groupId: group.id, groupFilter: groupFilter)
        }
    }

    // Board record subscriptions are namespaced per screen: backend group ids are
    // deterministic (option id / md5 of option ids), so two open sets grouped by the
    // same relation would otherwise collide on the shared subscription registry.
    private func recordsSubscriptionId(for groupId: String) -> String {
        "\(setSubscriptionDataBuilder.subscriptionId)-Group-\(groupId)"
    }

    private var optionsSubscriptionId: String {
        "\(setSubscriptionDataBuilder.subscriptionId)-Options"
    }

    // Column headers must follow option rename/recolor live; per-column dependency
    // details cover only options referenced by loaded records, so an empty column
    // would otherwise have no resolvable header.
    private func startOptionsSubscription() async {
        let relationKey = activeView.groupRelationKey
        guard relationKey.isNotEmpty else { return }

        let data = SubscriptionData.search(
            SubscriptionData.Search(
                identifier: optionsSubscriptionId,
                spaceId: setDocument.spaceId,
                filters: [
                    SearchHelper.layoutFilter([.relationOption]),
                    SearchHelper.relationKey(relationKey),
                    SearchHelper.isDeletedFilter(isDeleted: false),
                    SearchHelper.isArchivedFilter(isArchived: false)
                ],
                limit: 0,
                keys: [
                    BundledPropertyKey.id.rawValue,
                    BundledPropertyKey.name.rawValue,
                    BundledPropertyKey.relationOptionColor.rawValue
                ],
                noDepSubscription: true
            )
        )

        let subscription = subscriptionStorages[optionsSubscriptionId] ?? subscriptionStorageProvider.createSubscriptionStorage(subId: optionsSubscriptionId)
        subscriptionStorages[optionsSubscriptionId] = subscription

        try? await subscription.startOrUpdateSubscription(data: data) { [weak self] state in
            await self?.updateGroupOptionDetails(with: state)
        }
    }

    private func updateGroupOptionDetails(with state: SubscriptionStorageState) {
        groupOptionDetails = Dictionary(uniqueKeysWithValues: state.items.map { ($0.id, $0) })
    }

    // Cancelling the client-side stream does not cancel the server-side subscription;
    // stale ids must be stopped explicitly before the tracked set is overwritten.
    private func stopStaleGroupSubscriptions(activeGroupIds: [String]) async {
        let activeSubscriptionIds = Set(activeGroupIds.map { recordsSubscriptionId(for: $0) } + [setSubscriptionDataBuilder.subscriptionId, optionsSubscriptionId])
        let flatSubscriptionId = setSubscriptionDataBuilder.subscriptionId
        let staleSubscriptionIds = subscriptionStorages.keys.filter { !activeSubscriptionIds.contains($0) }
        for subscriptionId in staleSubscriptionIds {
            try? await subscriptionStorages[subscriptionId]?.stopSubscription()
            subscriptionStorages[subscriptionId] = nil
        }

        let activeGroupIdsSet = Set(activeGroupIds)
        let staleGroupIds = recordsDict.keys.filter { $0 != flatSubscriptionId && !activeGroupIdsSet.contains($0) }
        guard !staleGroupIds.isEmpty else { return }
        for groupId in staleGroupIds {
            recordsDict[groupId] = nil
            totalsDict[groupId] = nil
            pagitationDataDict[groupId] = nil
        }
        var configurations = configurationsDict
        staleGroupIds.forEach { configurations[$0] = nil }
        configurationsDict = configurations
    }
    
    private func setupPaginationDataIfNeeded(groupId: String) {
        guard pagitationDataDict[groupId] == nil else { return }
        pagitationDataDict[groupId] = EditorSetPaginationData.empty
    }
    
    private func startSubscriptionIfNeeded(subscriptionId: String, groupId: String, groupFilter: DataviewFilter? = nil) async {
        let pagitationData = pagitationData(by: groupId)
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

        let subscriptionData = SetSubscriptionData(
            identifier: subscriptionId,
            document: setDocument,
            groupFilter: groupFilter,
            currentPage: currentPage,
            numberOfRowsPerPage: numberOfRowsPerPage,
            collectionId: setDocument.isCollection() ? objectId : nil,
            objectOrderIds: setDocument.objectOrderIds(for: groupId),
            spaceType: spaceView?.spaceType
        )
        let data = setSubscriptionDataBuilder.set(subscriptionData)

        let subscription = subscriptionStorages[data.identifier] ?? subscriptionStorageProvider.createSubscriptionStorage(subId: data.identifier)
        subscriptionStorages[data.identifier] = subscription

        try? await subscription.startOrUpdateSubscription(data: data) { [weak self] state in
            await self?.updateData(with: groupId, numberOfRowsPerPage: numberOfRowsPerPage, state: state)
        }
    }

    private func updateData(with groupId: String, numberOfRowsPerPage: Int, state: SubscriptionStorageState) {
        // A stopped column's storage can still deliver an in-flight update; accepting it
        // would resurrect the removed column.
        guard subscriptionStorage(for: groupId) != nil else { return }
        let pagesCount = numberOfRowsPerPage > 0 ? Int(ceil(Float(state.total) / Float(numberOfRowsPerPage))) : 0
        updatePageCount(pagesCount, groupId: groupId, ignorePageLimit: activeView.type.hasGroups)
        recordsDict[groupId] = state.items
        totalsDict[groupId] = state.total
        updateConfigurations(with: [groupId])
    }
    
    private func stopAllSubscriptionStorages() async {
        await subscriptionStorages.values.asyncForEach { try? await $0.stopSubscription() }
    }
    
    private func updateConfigurations(with groupIds: [String]) {
        var tempConfigurationsDict = configurationsDict
        for groupId in groupIds {
            guard let subscription = subscriptionStorage(for: groupId) else {
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
                    chatPreviews: chatPreviews,
                    spaceView: spaceView,
                    onItemTap: { [weak self] details in
                        self?.itemTapped(details)
                    }
                )
                tempConfigurationsDict[groupId] = configurations
            }
        }
        let sortedDict = sortedConfigurationsDict(with: tempConfigurationsDict)
        // Diff-guard: skip publish when unchanged; SetContentViewItemConfiguration is Equatable.
        guard sortedDict != configurationsDict else { return }
        configurationsDict = sortedDict
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
        // Row closures capture a details snapshot; the configurations diff-guard can keep a row
        // whose navigation-relevant fields (bookmark source, chatId, layout) changed invisibly.
        let freshDetails = subscriptionStorages.values.compactMap { $0.detailsStorage.get(id: details.id) }.first
        openObject(details: freshDetails ?? details)
    }
    
    private func clearState() async {
        boardSubscriptionsEpoch += 1
        recordsDict = [:]
        totalsDict = [:]
        configurationsDict = [:]
        pagitationDataDict = [:]
        groups = []
        groupOptionDetails = [:]
        boardState = .loading
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
        output?.showCreateObject(document: setDocument, setting: setting, prefilledFields: [:])
    }

    var canCreateCardInColumn: Bool {
        setDocument.setPermissions.canCreateObject
    }

    func onCreateObjectInColumnTap(_ groupId: String) {
        guard setDocument.setPermissions.canCreateObject else { return }
        let groupValue = groups.first { $0.id == groupId }?.value
        var prefilledFields = [String: Google_Protobuf_Value]()
        if let value = SetKanbanCardMove.prefilledValue(targetGroupValue: groupValue) {
            prefilledFields[activeView.groupRelationKey] = value
        }
        output?.showCreateObject(document: setDocument, setting: nil, prefilledFields: prefilledFields)
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

    func onTapWidgets() {
        output?.onWidgetsSelected(spaceId: setDocument.spaceId)
    }

    func showRelationValueEditingView(key: String) {
        if key == BundledPropertyKey.setOf.rawValue {
            showSetOfTypeSelection()
            return
        }
        
        let relation = setDocument.parsedProperties.installed.first { $0.key == key }
        guard let relation = relation else { return }
        guard let objectDetails = setDocument.details else {
            anytypeAssertionFailure("Set document doesn't contains details")
            return
        }
        
        output?.showRelationValueEditingView(objectDetails: objectDetails, relation: relation)
    }
    
    func showRelationValueEditingView(
        objectId: String,
        relation: Property
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

    func showSetSettings() {
        guard let detailsStorage = defaultSubscriptionDetailsStorage() else { return }
        output?.showSetViewSettings(document: setDocument, subscriptionDetailsStorage: detailsStorage)
    }

    func objectOrderUpdate(with groupObjectIds: [GroupObjectIds]) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.dataviewService.objectOrderUpdate(
                    objectId: setDocument.objectId,
                    blockId: setDocument.blockId,
                    order: groupObjectIds.map { DataviewObjectOrder(viewID: self.activeView.id, groupID: $0.groupId, objectIds: $0.objectIds) }
                )
            } catch {
                revertOptimisticCardMoves()
                output?.showFailureToast(message: error.localizedDescription)
            }
        }
    }
    
    func showKanbanColumnSettings(for groupId: String) {
        guard setDocument.setPermissions.canEditView else { return }
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
