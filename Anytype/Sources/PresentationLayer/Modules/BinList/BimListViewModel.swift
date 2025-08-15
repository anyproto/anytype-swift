import Combine
import Services
import SwiftUI

@MainActor
final class BinListViewModel: ObservableObject {
    
    private let spaceId: String
    @Injected(\.binSubscriptionService)
    private var binSubscriptionService: any BinSubscriptionServiceProtocol
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    
    private var details: [ObjectDetails] = []
    private var selectedIds: Set<String> = []
    
    @Published var rows: [BinListRowModel] = []
    @Published var searchText: String = ""
    @Published var viewEditMode: EditMode = .inactive
    @Published var binAlertData: BinConfirmationAlertData? = nil
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func startSubscription() async {
        for await value in await binSubscriptionService.dataSequence {
            details = value
            updateRows()
        }
    }
    
    func onSearch() async throws {
        await binSubscriptionService.startSubscription(spaceId: spaceId, objectLimit: nil, name: searchText)
    }
     
    func onTapRow(row: BinListRowModel) {
        // TODO: Output
    }
    
    func onCheckboxTap(row: BinListRowModel) {
        if selectedIds.contains(row.objectId) {
            selectedIds.remove(row.objectId)
        } else {
            selectedIds.insert(row.objectId)
        }
        updateRows()
    }
    
    func onTapSelecObjects() {
        viewEditMode = .active
    }
    
    func onTapDone() {
        viewEditMode = .inactive
    }
    
    func onTapEmptyBin() async throws {
        let binIds = try await searchService.searchArchiveObjectIds(spaceId: spaceId)
        binAlertData = BinConfirmationAlertData(ids: binIds)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    // MARK: - Private
    
    private func updateRows() {
        rows = details.map { detail in
            BinListRowModel(
                objectId: detail.id,
                icon: detail.objectIconImage,
                title: detail.title,
                description: detail.subtitle,
                subtitle: detail.objectType.displayName,
                selected: selectedIds.contains(detail.id)
            )
        }
    }
}
