import Combine
import Services
import SwiftUI

@MainActor
final class BinListViewModel: ObservableObject {
    
    private let spaceId: String
    @Injected(\.binSearchService)
    private var binSearchService: any BinSearchServiceProtocol
    
    private var details: [ObjectDetails] = []
    private var selectedIds: Set<String> = []
    
    @Published var rows: [BinListRowModel] = []
    @Published var searchText: String = ""
    @Published var viewEditMode: EditMode = .inactive
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func onSearch() async throws {
        details = try await binSearchService.search(text: searchText, spaceId: spaceId)
        updateRows()
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
    
    func onTapEmptyBin() {
        
    }
    
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
