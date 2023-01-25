import Foundation
import SwiftUI
import BlocksModels
import Combine

final class SetSortsListViewModel: ObservableObject {
    @Published var rows: [SetSortRowConfiguration] = []
    
    private let setDocument: SetDocumentProtocol
    private var cancellable: Cancellable?
    
    private let dataviewService: DataviewServiceProtocol
    private let router: EditorSetRouterProtocol
    
    init(
        setDocument: SetDocumentProtocol,
        dataviewService: DataviewServiceProtocol,
        router: EditorSetRouterProtocol)
    {
        self.setDocument = setDocument
        self.dataviewService = dataviewService
        self.router = router
        self.setup()
    }
    
}

extension SetSortsListViewModel {
    
    // MARK: - Routing
    
    func addButtonTapped() {
        let excludeRelations: [RelationDetails] = setDocument.sorts.map { $0.relationDetails }
        router.showRelationSearch(
            relationsDetails: setDocument.activeViewRelations(excludeRelations: excludeRelations))
        { [weak self] relationDetails in
            self?.addNewSort(with: relationDetails)
        }
    }
    
    func rowTapped(_ id: String) {
        guard let setSort = setDocument.sorts.first(where: { $0.id == id }) else {
            return
        }
        router.showSortTypesList(
            setSort: setSort,
            onSelect: { [weak self] newSetSort in
                self?.updateSorts(with: newSetSort)
            }
        )
    }
    
    // MARK: - Actions
    
    func delete(_ indexSet: IndexSet) {
        indexSet.forEach { [weak self] deleteIndex in
            guard let self, deleteIndex < self.setDocument.sorts.count else { return }
            let sort = self.setDocument.sorts[deleteIndex]
            Task {
                try await dataviewService.removeSorts([sort.sort.id], viewId: self.setDocument.activeView.id)
            }
        }
    }
    
    func move(from: IndexSet, to: Int) {
        Task {
            var sorts = setDocument.sorts
            sorts.move(fromOffsets: from, toOffset: to)
            let sortIds = sorts.map { $0.sort.id }
            try await dataviewService.sortSorts(sortIds, viewId: setDocument.activeView.id)
        }
    }
    
    func addNewSort(with relation: RelationDetails) {
        let newSort = DataviewSort(
            relationKey: relation.key,
            type: .asc
        )
        Task {
            try await dataviewService.addSort(newSort, viewId: setDocument.activeView.id)
        }
    }
    
    private func setup() {
        cancellable = setDocument.sortsPublisher.sink { [weak self] sorts in
            self?.updateRows(with: sorts)
        }
    }
    
    private func updateRows(with sorts: [SetSort]) {
        rows = sorts.map {
            SetSortRowConfiguration(
                id: $0.id,
                title: $0.relationDetails.name,
                subtitle: $0.typeTitle(),
                iconAsset: $0.relationDetails.format.iconAsset
            )
        }
    }
    
    private func updateSorts(with setSort: SetSort) {
        Task {
            try await dataviewService.replaceSort(
                setSort.sort.id,
                with: setSort.sort,
                viewId: setDocument.activeView.id
            )
        }
    }
}
