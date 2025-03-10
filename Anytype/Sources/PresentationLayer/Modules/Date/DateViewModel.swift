import SwiftUI
import Services

@MainActor
final class DateViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let spaceId: String
    private weak var output: (any DateModuleOutput)?
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()
    private let dateFormatter = DateFormatter.defaultDateFormatter
    
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.relationListWithValueService)
    private var relationListWithValueService: any RelationListWithValueServiceProtocol
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: any RelationDetailsStorageProtocol
    @Injected(\.dateRelatedObjectsSubscriptionService)
    private var dateRelatedObjectsSubscriptionService: any DateRelatedObjectsSubscriptionServiceProtocol
    @Injected(\.objectDateByTimestampService)
    private var objectDateByTimestampService: any ObjectDateByTimestampServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionService: any ObjectActionsServiceProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantStorage: any AccountParticipantsStorageProtocol
    
    // MARK: - State
    
    private var objectsToLoad = 0
    private var lastSelectedRelation: RelationDetails? = nil
    private var details = [ObjectDetails]()
    
    @Published var document: (any BaseDocumentProtocol)?
    @Published var title = ""
    @Published var relativeTag = ""
    @Published var weekday = ""
    @Published var objects = [ObjectCellData]()
    @Published var relationItems = [RelationItemData]()
    @Published var state = DateModuleState()
    @Published var syncStatusData = SyncStatusData(status: .offline, networkId: "", isHidden: true)
    @Published var scrollToRelationId: String? = nil
    @Published private var participantCanEdit = false
    
    init(date: Date?, spaceId: String, output: (any DateModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output
        
        let date = date ?? Date()
        updateDate(date)
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenDate()
    }
    
    func onDisappear() {
        stopSubscription()
    }
    
    func documentDidChange() async {
        async let detailsSubscription: () = subscribeOnDetails()
        async let syncStatusSubscription: () = subscribeOnSyncStatus()
        async let participantSubscription: () = subscribeOnParticipant()
        async let relationListUpdate: () = getRelationsList()
        (_, _, _, _) = await (detailsSubscription, syncStatusSubscription, participantSubscription, relationListUpdate)
    }
    
    func restartRelationSubscription(with state: DateModuleState) async {
        let filters = buildFilters(from: state)
        guard filters.isNotEmpty, let sort = buildSort(from: state) else { return }
        
        await dateRelatedObjectsSubscriptionService.startSubscription(
            spaceId: spaceId,
            filters: filters,
            sort: sort,
            limit: state.limit,
            update: { [weak self] details, objectsToLoad  in
                self?.objectsToLoad = objectsToLoad
                self?.details = details
                self?.updateRows()
            }
        )
    }
    
    func onAppearLastRow(_ id: String) {
        guard objectsToLoad > 0, objects.last?.id == id else { return }
        objectsToLoad = 0
        state.updateLimit()
    }
    
    func onSyncStatusTap() {
        output?.onSyncStatusTap()
    }
    
    func onRelationTap(_ details: RelationDetails) {
        if state.selectedRelation != details {
            state.selectedRelation = details
            AnytypeAnalytics.instance().logSwitchRelationDate(key: details.analyticsKey)
        } else {
            state.sortType = state.sortType == .asc ? .desc : .asc
            AnytypeAnalytics.instance().logObjectListSort(route: .screenDate, type: state.sortType.analyticValue)
        }
    }
    
    func onRelationsListTap() {
        guard relationItems.isNotEmpty else { return }
        let items = relationItems.map { item in
            SimpleSearchListItem(icon: item.icon, title: item.title) { [weak self] in
                self?.state.selectedRelation = item.details
                self?.scrollToRelationId = item.id
            }
        }
        output?.onSearchListTap(items: items)
    }
    
    func onCalendarTap() {
        guard let currentDate = state.currentDate else { return }
        output?.onCalendarTap(with: currentDate, completion: { [weak self] newDate in
            self?.updateDate(newDate)
        })
        AnytypeAnalytics.instance().logClickDateCalendarView()
    }
    
    func onPrevDayTap() {
        guard let prevDay = state.currentDate?.prevDay() else { return }
        updateDate(prevDay)
        AnytypeAnalytics.instance().logClickDateBack()
    }
    
    func onNextDayTap() {
        guard let nextDay = state.currentDate?.nextDay() else { return }
        updateDate(nextDay)
        AnytypeAnalytics.instance().logClickDateForward()
    }
    
    func hasPrevDay() -> Bool {
        guard let prevDay = state.currentDate?.prevDay() else { return false }
        return ClosedRange.anytypeDateRange.contains(prevDay)
    }
    
    func hasNextDay() -> Bool {
        guard let nextDay = state.currentDate?.nextDay() else { return false }
        return ClosedRange.anytypeDateRange.contains(nextDay)
    }
    
    func updateDate(_ date: Date) {
        Task {
            guard let details = try? await objectDateByTimestampService.objectDateByTimestamp(
                date.timeIntervalSince1970,
                spaceId: spaceId
            ) else { return }
            
            document = openDocumentProvider.document(objectId: details.id, spaceId: details.spaceId, mode: .preview)
        }
    }
    
    func onDelete(objectId: String) {
        setArchive(objectId: objectId)
    }
    
    func resetScrollToRelationIdIfNeeded(id: String) {
        guard scrollToRelationId == id else { return }
        scrollToRelationId = nil
    }
    
    // MARK: - Object updates / subscriptions
    
    private func subscribeOnSyncStatus() async {
        guard let document else { return }
        for await status in document.syncStatusDataPublisher.values {
            syncStatusData = SyncStatusData(status: status.syncStatus, networkId: accountManager.account.info.networkId, isHidden: false)
        }
    }
    
    private func subscribeOnDetails() async {
        guard let document else { return }
        for await details in document.detailsPublisher.values {
            if let date = details.timestamp {
                title = dateFormatter.string(from: date)
                relativeTag = relativeTag(date: date)
                let weekdayIndex = Calendar.current.component(.weekday, from: date) - 1
                if dateFormatter.weekdaySymbols.count > weekdayIndex {
                    weekday = dateFormatter.weekdaySymbols[weekdayIndex]
                }
            }
            state.currentDate = details.timestamp
        }
    }
    
    func subscribeOnParticipant() async {
        for await participant in accountParticipantStorage.participantPublisher(spaceId: spaceId).values {
            participantCanEdit = participant.canEdit
            updateRows()
        }
    }
    
    private func getRelationsList() async {
        guard let document else { return }
        let relationsKeys = try? await relationListWithValueService.relationListWithValue(
            document.objectId,
            spaceId: document.spaceId
        )
        let relationDetails = relationDetails(for: relationsKeys)
        
        relationItems = relationDetails.compactMap { [weak self] details in
            self?.relationItemData(from: details)
        }
        
        // Save last no nil selectedRelation to preselect it for another date
        if let selectedRelation = state.selectedRelation {
            lastSelectedRelation = selectedRelation
        }
        let prevSelectedRelation = relationDetails.first { $0.id == lastSelectedRelation?.id } ?? relationDetails.first
        state.selectedRelation = prevSelectedRelation
    }
    
    // MARK: - Private
    
    private func relationDetails(for relationsKeys: [String]?) -> [RelationDetails] {
        guard let relationsKeys else { return [] }
        let relationDetails = relationsKeys.compactMap { [weak self] key -> RelationDetails? in
            guard let self else { return nil }
            return try? relationDetailsStorage.relationsDetails(key: key, spaceId: spaceId)
        }
        return relationDetails.filter { details in
            if details.key == BundledRelationKey.mentions.rawValue {
                return true
            }
            if details.key == BundledRelationKey.links.rawValue ||
                details.key == BundledRelationKey.backlinks.rawValue {
                return false
            }
            return !details.isHidden
        }
    }
    
    private func updateRows() {
        objects = details.map { details in
            ObjectCellData(
                id: details.id,
                icon: details.objectIconImage,
                title: details.title,
                type: details.objectType.displayName,
                canArchive: details.permissions(participantCanEdit: participantCanEdit).canArchive,
                onTap: { [weak self] in
                    self?.output?.onObjectTap(data: details.screenData())
                }
            )
        }
    }
    
    private func stopSubscription() {
        Task {
            await dateRelatedObjectsSubscriptionService.stopSubscription()
        }
    }
    
    private func buildFilters(from state: DateModuleState) -> [DataviewFilter] {
        guard let document, let relationDetails = state.selectedRelation else { return [] }
        
        switch relationDetails.format {
        case .date:
            let dateRelationFilter = dateRelationFilter(key: relationDetails.key, date: state.currentDate)
            let creatorFilter = creatorFilter()
            let creationDateCompositFilter = creationDateCompositFilter()
            return [dateRelationFilter, creatorFilter, creationDateCompositFilter].compactMap { $0 }
        default:
            let objectRelationFilter = objectRelationFilter(key: relationDetails.key, value: document.objectId)
            return [objectRelationFilter]
        }
    }
    
    private func dateRelationFilter(key: String, date: Date?) -> DataviewFilter? {
        guard let date = date else { return nil }
        
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = date.timeIntervalSince1970.protobufValue
        filter.format = .date
        filter.relationKey = key
        
        return filter
    }
    
    private func creatorFilter() -> DataviewFilter? {
        guard state.selectedRelation?.key == BundledRelationKey.createdDate.rawValue else {
            return nil
        }
        var filter = DataviewFilter()
        filter.condition = .notEqual
        filter.value = ObjectOrigin.builtin.rawValue.protobufValue
        filter.relationKey = BundledRelationKey.origin.rawValue
        
        return filter
    }
    
    private func creationDateCompositFilter() -> DataviewFilter? {
        guard state.selectedRelation?.key == BundledRelationKey.lastModifiedDate.rawValue else {
            return nil
        }
        var filter = DataviewFilter()
        filter.condition = .notEqual
        filter.value = [
            Constants.relationKey : BundledRelationKey.lastModifiedDate.rawValue.protobufValue,
            Constants.typeKey : Constants.typeValue.protobufValue
        ].protobufValue
        filter.relationKey = BundledRelationKey.createdDate.rawValue
        
        return filter
    }
    
    private func objectRelationFilter(key: String, value: String) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = value.protobufValue
        filter.relationKey = key
        
        return filter
    }
    
    private func buildSort(from state: DateModuleState) -> DataviewSort? {
        guard let relationDetails = state.selectedRelation else { return nil }
        
        let relationKey = relationDetails.format == .date ? relationDetails.key : BundledRelationKey.lastOpenedDate.rawValue
        return SearchHelper.sort(
            relationKey: relationKey,
            type: state.sortType
        )
    }
    
    private func relationItemData(from details: RelationDetails) -> RelationItemData {
        let isMention = details.key == BundledRelationKey.mentions.rawValue
        let icon: Icon? = isMention ? .asset(.X24.mention) : nil
        return RelationItemData(
            id: details.id,
            icon: icon,
            title: details.name,
            details: details
        )
    }
    
    private func setArchive(objectId: String) {
        AnytypeAnalytics.instance().logMoveToBin(true)
        Task { try? await objectActionService.setArchive(objectIds: [objectId], true) }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    private func relativeTag(date: Date) -> String {
        if Calendar.current.isDateInYesterday(date) {
            return Loc.yesterday
        }
        if Calendar.current.isDateInToday(date) {
            return Loc.today
        }
        if Calendar.current.isDateInTomorrow(date) {
            return Loc.tomorrow
        }
        return ""
    }
}

private extension DateViewModel {
    enum Constants {
        static let relationKey = "relationKey"
        static let typeKey = "type"
        static let typeValue = "valueFromRelation"
    }
}
