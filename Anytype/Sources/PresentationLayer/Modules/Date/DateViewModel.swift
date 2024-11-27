import SwiftUI
import Services

@MainActor
final class DateViewModel: ObservableObject {
    
    // MARK: - DI
    
    private weak var output: (any DateModuleOutput)?
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.documentService()
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
    
    // MARK: - State
    
    private var objectsToLoad = 0
    private var lastSelectedRelation: RelationDetails? = nil
    
    @Published var document: any BaseDocumentProtocol
    @Published var title = ""
    @Published var objects = [ObjectCellData]()
    @Published var relationItems = [RelationItemData]()
    @Published var state = DateModuleState()
    @Published var syncStatusData = SyncStatusData(status: .offline, networkId: "", isHidden: true)
    
    init(objectId: String, spaceId: String, output: (any DateModuleOutput)?) {
        self.output = output
        self.document = openDocumentProvider.document(objectId: objectId, spaceId: spaceId, mode: .preview)
    }
    
    func onDisappear() {
        stopSubscription()
    }
    
    func documentDidChange() async {
        async let detailsSubscription: () = subscribeOnDetails()
        async let syncStatusSubscription: () = subscribeOnSyncStatus()
        async let relationListUpdate: () = getRelationsList()
        (_, _, _) = await (detailsSubscription, syncStatusSubscription, relationListUpdate)
    }
    
    func restartRelationSubscription(with state: DateModuleState) async {
        guard let filter = buildFilter(from: state),
              let sort = buildSort(from: state) else { return }
        
        await dateRelatedObjectsSubscriptionService.startSubscription(
            spaceId: document.spaceId,
            filter: filter,
            sort: sort,
            limit: state.limit,
            update: { [weak self] details, objectsToLoad  in
                self?.objectsToLoad = objectsToLoad
                self?.updateRows(with: details)
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
        } else {
            state.sortType = state.sortType == .asc ? .desc : .asc
        }
    }
    
    func onRelationsListTap() {
        guard relationItems.isNotEmpty else { return }
        let items = relationItems.map { item in
            SimpleSearchListItem(icon: item.icon, title: item.title) { [weak self] in
                self?.state.selectedRelation = item.details
            }
        }
        output?.onSearchListTap(items: items)
    }
    
    func onCalendarTap() {
        guard let currentDate = state.currentDate else { return }
        output?.onCalendarTap(with: currentDate, completion: { [weak self] newDate in
            self?.updateDate(newDate)
        })
    }
    
    func onPrevDayTap() {
        guard let prevDay = state.currentDate?.prevDay() else { return }
        updateDate(prevDay)
    }
    
    func onNextDayTap() {
        guard let nextDay = state.currentDate?.nextDay() else { return }
        updateDate(nextDay)
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
                spaceId: document.spaceId
            ) else { return }
            
            document = openDocumentProvider.document(objectId: details.id, spaceId: details.spaceId, mode: .preview)
        }
    }
    
    // MARK: - Object updates / subscriptions
    
    private func subscribeOnSyncStatus() async {
        for await status in document.syncStatusDataPublisher.values {
            syncStatusData = SyncStatusData(status: status.syncStatus, networkId: accountManager.account.info.networkId, isHidden: false)
        }
    }
    
    private func subscribeOnDetails() async {
        for await details in document.detailsPublisher.values {
            if let date = details.timestamp {
                title = dateFormatter.string(from: date)
            }
            state.currentDate = details.timestamp
        }
    }
    
    private func getRelationsList() async {
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
            return try? relationDetailsStorage.relationsDetails(key: key, spaceId: document.spaceId)
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
    
    private func updateRows(with details: [ObjectDetails]) {
        objects = details.map { details in
            ObjectCellData(
                id: details.id,
                icon: details.objectIconImage,
                title: details.title,
                type: details.objectType.name,
                onTap: { [weak self] in
                    self?.output?.onObjectTap(data: details.editorScreenData())
                }
            )
        }
    }
    
    private func stopSubscription() {
        Task {
            await dateRelatedObjectsSubscriptionService.stopSubscription()
        }
    }
    
    private func buildFilter(from state: DateModuleState) -> DataviewFilter? {
        guard let relationDetails = state.selectedRelation else { return nil }
        
        switch relationDetails.format {
        case .date:
            return dateRelationFilter(key: relationDetails.key, date: state.currentDate)
        default:
            return objectRelationFilter(key: relationDetails.key, value: document.objectId)
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
        let title = isMention ? Loc.Relation.Mention.title : details.name
        return RelationItemData(
            icon: icon,
            title: title,
            details: details
        )
    }
}
