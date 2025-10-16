import Combine
import Services
import SwiftUI

@MainActor
final class BinListViewModel: ObservableObject, OptionsItemProvider {
    
    private let spaceId: String
    private weak var output: (any WidgetObjectListCommonModuleOutput)?
    @Injected(\.binSubscriptionService)
    private var binSubscriptionService: any BinSubscriptionServiceProtocol
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @Injected(\.participantsStorage)
    private var accountParticipantStorage: any ParticipantsStorageProtocol
    @Injected(\.objectActionsService)
    private var objectActionService: any ObjectActionsServiceProtocol
    
    private var details: [ObjectDetails] = []
    private var participant: Participant?
    
    @Published var rows: [BinListRowModel] = []
    @Published var searchText: String = ""
    @Published var viewEditMode: EditMode = .inactive
    @Published var binAlertData: BinConfirmationAlertData? = nil
    @Published var selectedIds: Set<String> = []
    @Published var canDelete: Bool = false
    @Published var canRestore: Bool = false
    
    var allowEdit: Bool { canDelete || canRestore }
    var showOptionsView: Bool { selectedIds.isNotEmpty && allowEdit }
    var binIsEmpty: Bool { details.isEmpty && searchText.isEmpty }
    
    // MARK: - OptionsItemProvider
    
    var optionsPublisher: AnyPublisher<[SelectionOptionsItemViewModel], Never> { $options.eraseToAnyPublisher() }
    @Published var options = [SelectionOptionsItemViewModel]()
    
    init(spaceId: String, output: (any WidgetObjectListCommonModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output
    }
    
    func startSubscriptions() async {
        async let binSub: () = subscribeOnBin()
        async let participantSub: () = subscribeOnParticipant()
        
        _ = await (binSub, participantSub)
    }
    
    func startSubscription() async {
        for await value in await binSubscriptionService.dataSequence {
            details = value
            updateView()
        }
    }
    
    func onSearch() async throws {
        await binSubscriptionService.startSubscription(spaceId: spaceId, objectLimit: nil, name: searchText)
    }
     
    func onTapRow(row: BinListRowModel) {
        guard let detail = details.first(where: { $0.id == row.objectId }) else { return }
        output?.onObjectSelected(screenData: detail.screenData())
    }
    
    func onCheckboxTap(row: BinListRowModel) {
        if selectedIds.contains(row.objectId) {
            selectedIds.remove(row.objectId)
        } else {
            selectedIds.insert(row.objectId)
        }
        updateView()
    }
    
    func onTapSelecObjects() {
        viewEditMode = .active
    }
    
    func onTapDone() {
        viewEditMode = .inactive
        selectedIds.removeAll()
        updateView()
    }
    
    func onTapEmptyBin() async throws {
        let binIds = try await searchService.searchArchiveObjectIds(spaceId: spaceId)
        delete(objectIds: binIds)
    }
    
    func onDelete(row: BinListRowModel) {
        delete(objectIds: [row.objectId])
    }
    
    func onRestore(row: BinListRowModel) {
        restore(objectIds: [row.objectId])
    }
    
    // MARK: - Private
    
    private func subscribeOnBin() async {
        for await value in await binSubscriptionService.dataSequence {
            details = value
            updateView()
        }
    }
    
    private func subscribeOnParticipant() async {
        for await participant in accountParticipantStorage.participantPublisher(spaceId: spaceId).values {
            self.participant = participant
            updateView()
        }
    }
    
    private func updateView() {
        rows = details.map { detail in
            
            let permissions = detail.permissions(participant: participant)
            
            return BinListRowModel(
                objectId: detail.id,
                icon: detail.objectIconImage,
                title: detail.title,
                description: detail.subtitle,
                subtitle: detail.objectType.displayName,
                selected: selectedIds.contains(detail.id),
                canDelete: permissions.canDelete,
                canRestore: permissions.canRestore
            )
        }
        
        canDelete = rows.contains { $0.canDelete }
        canRestore = rows.contains { $0.canRestore }
        
        options = .builder {
            if canDelete {
                SelectionOptionsItemViewModel(
                    id: "delete",
                    title: Loc.delete,
                    imageAsset: .X32.delete,
                    action: { [weak self] in
                        self?.deleteSelected()
                    }
                )
            }
            
            if canRestore {
                SelectionOptionsItemViewModel(
                    id: "restore",
                    title: Loc.restore,
                    imageAsset: .X32.restore,
                    action: { [weak self] in
                        self?.restoreSelected()
                    }
                )
            }
            
        }
    }
    
    private func deleteSelected() {
        delete(objectIds: Array(selectedIds))
    }
    
    private func restoreSelected() {
        restore(objectIds: Array(selectedIds))
    }
    
    private func delete(objectIds: [String]) {
        binAlertData = BinConfirmationAlertData(ids: objectIds)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    private func restore(objectIds: [String]) {
        AnytypeAnalytics.instance().logMoveToBin(false)
        Task { try? await objectActionService.setArchive(objectIds: objectIds, false) }
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
