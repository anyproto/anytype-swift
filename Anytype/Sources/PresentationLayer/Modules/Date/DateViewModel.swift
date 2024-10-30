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
    @Published var title = ""
    @Published var objects = [ObjectCellData]()
    @Published var relationDetails = [RelationDetails]()
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
        // TODO: get relationsKeys from middle (it doesn't work now)
//        let relationsKeys = try? await relationListWithValueService.relationListWithValue(objectId, spaceId: spaceId)
        let relationsKeys = [BundledRelationKey.links, BundledRelationKey.backlinks]
        relationDetails = relationsKeys.compactMap { [weak self] key -> RelationDetails? in
            guard let self else { return nil }
            return try? relationDetailsStorage.relationsDetails(for: key, spaceId: spaceId)
        }
        state.selectedRelation = relationDetails.first
    }
    
    func restartSubscription(with state: DateModuleState) async {
        guard let relationKey = state.selectedRelation?.key else { return }
        await dateRelatedObjectsSubscriptionService.startSubscription(
            objectId: objectId,
            spaceId: spaceId,
            relationKey: relationKey,
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
        guard relationDetails.isNotEmpty else { return }
        let items = relationDetails.map { details in
            SimpleSearchListItem(icon: nil, title: details.name) { [weak self] in
                self?.state.selectedRelation = details
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
}
