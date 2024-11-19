import SwiftUI
import Services

@MainActor
final class DateViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let objectId: String
    private let spaceId: String
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
    
    // MARK: - State
    
    private let document: any BaseDocumentProtocol
    private var objectsToLoad = 0
    private var currentDate: Date? = nil
    
    @Published var title = ""
    @Published var objects = [ObjectCellData]()
    @Published var relationItems = [RelationItemData]()
    @Published var state = DateModuleState()
    @Published var syncStatusData = SyncStatusData(status: .offline, networkId: "", isHidden: true)
    
    init(objectId: String, spaceId: String, output: (any DateModuleOutput)?) {
        self.spaceId = spaceId
        self.objectId = objectId
        self.output = output
        self.document = openDocumentProvider.document(objectId: objectId, spaceId: spaceId)
    }
    
    func onDisappear() {
        stopSubscription()
    }
    
    func getRelationsList() async {
        let relationsKeys = try? await relationListWithValueService.relationListWithValue(objectId, spaceId: spaceId)
        // Set mentions relation first
        let reorderedRelationsKeys = relationsKeys?.reordered(by: [BundledRelationKey.mentions.rawValue], transform: { $0 }) ?? []
        let relationDetails = reorderedRelationsKeys.compactMap { [weak self] key -> RelationDetails? in
            guard let self else { return nil }
            return try? relationDetailsStorage.relationsDetails(for: key, spaceId: spaceId)
        }
        relationItems = relationDetails.compactMap { [weak self] details in
            self?.relationItemData(from: details)
        }
        state.selectedRelation = relationDetails.first
    }
    
    func restartSubscription(with state: DateModuleState) async {
        guard let filter = buildFilter(from: state) else { return }
        await dateRelatedObjectsSubscriptionService.startSubscription(
            spaceId: spaceId,
            filter: filter,
            limit: state.limit,
            update: { [weak self] details, objectsToLoad  in
                self?.objectsToLoad = objectsToLoad
                self?.updateRows(with: details)
            }
        )
    }
    
    func subscribeOnSyncStatus() async {
        for await status in document.syncStatusDataPublisher.values {
            syncStatusData = SyncStatusData(status: status.syncStatus, networkId: accountManager.account.info.networkId, isHidden: false)
        }
    }
    
    func subscribeOnDetails() async {
        for await details in document.detailsPublisher.values {
            title = details.title
            state.currentDate = details.timestamp
        }
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
            return objectRelationFilter(key: relationDetails.key, value: objectId)
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
