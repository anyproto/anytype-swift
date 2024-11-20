import SwiftUI
import Services

@MainActor
final class DateViewModel: ObservableObject {
    
    // MARK: - DI
    
    private weak var output: (any DateModuleOutput)?
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.documentService()
    
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
    
    @Published var document: any BaseDocumentProtocol
    @Published var title = ""
    @Published var objects = [ObjectCellData]()
    @Published var relationItems = [RelationItemData]()
    @Published var state = DateModuleState()
    @Published var syncStatusData = SyncStatusData(status: .offline, networkId: "", isHidden: true)
    
    init(objectId: String, spaceId: String, output: (any DateModuleOutput)?) {
        self.output = output
        self.document = openDocumentProvider.document(objectId: objectId, spaceId: spaceId)
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
        guard let filter = buildFilter(from: state) else { return }
        await dateRelatedObjectsSubscriptionService.startSubscription(
            spaceId: document.spaceId,
            filter: filter,
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
        state.selectedRelation = details
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
    
    func updateDate(_ date: Date) {
        Task {
            guard let details = try? await objectDateByTimestampService.objectDateByTimestamp(
                date.timeIntervalSince1970,
                spaceId: document.spaceId
            ) else { return }
            
            document = openDocumentProvider.document(objectId: details.id, spaceId: details.spaceId)
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
            title = details.title
            state.currentDate = details.timestamp
        }
    }
    
    private func getRelationsList() async {
        let relationsKeys = try? await relationListWithValueService.relationListWithValue(
            document.objectId,
            spaceId: document.spaceId
        )
        // Set mentions relation first
        let reorderedRelationsKeys = relationsKeys?.reordered(by: [BundledRelationKey.mentions.rawValue], transform: { $0 }) ?? []
        let relationDetails = reorderedRelationsKeys.compactMap { [weak self] key -> RelationDetails? in
            guard let self else { return nil }
            return try? relationDetailsStorage.relationsDetails(for: key, spaceId: document.spaceId)
        }
        relationItems = relationDetails.compactMap { [weak self] details in
            self?.relationItemData(from: details)
        }
        state.selectedRelation = relationDetails.first
    }
    
    // MARK: - Private
    
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
