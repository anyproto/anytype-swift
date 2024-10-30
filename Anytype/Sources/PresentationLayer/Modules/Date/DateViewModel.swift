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
    
    @Published var title = ""
    @Published var objects = [ObjectCellData]()
    @Published var relationDetails = [RelationDetails]()
    @Published var selectedRelation: RelationDetails?
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
        selectedRelation = relationDetails.first
    }
    
    func restartSubscription(with relationKey: String) async {
        await dateRelatedObjectsSubscriptionService.startSubscription(
            objectId: objectId,
            spaceId: spaceId,
            relationKey: relationKey,
            update: { [weak self] details in
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
    
    func onSyncStatusTap() {
        output?.onSyncStatusTap()
    }
    
    func onRelationTap(_ details: RelationDetails) {
        selectedRelation = details
    }
    
    // MARK: - Private
    
    private func updateRows(with details: [ObjectDetails]) {
        objects = details.map { details in
            ObjectCellData(
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
