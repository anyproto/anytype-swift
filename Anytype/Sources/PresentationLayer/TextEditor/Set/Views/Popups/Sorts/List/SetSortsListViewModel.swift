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
    
    func rowTapped(_ id: String, index: Int) {
        guard let setSort = setDocument.sorts[safe: index], setSort.id == id  else {
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
                AnytypeAnalytics.instance().logSortRemove(objectType: self.setDocument.analyticsType)
            }
        }
    }
    
    func move(from: IndexSet, to: Int) {
        Task {
            var sorts = setDocument.sorts
            sorts.move(fromOffsets: from, toOffset: to)
            let sortIds = sorts.map { $0.sort.id }
            try await dataviewService.sortSorts(sortIds, viewId: setDocument.activeView.id)
            AnytypeAnalytics.instance().logRepositionSort(objectType: setDocument.analyticsType)
        }
    }
    
    func addNewSort(with relation: RelationDetails) {
        let newSort = DataviewSort(
            relationKey: relation.key,
            type: .asc
        )
        Task {
            try await dataviewService.addSort(newSort, viewId: setDocument.activeView.id)
            AnytypeAnalytics.instance().logAddSort(objectType: setDocument.analyticsType)
        }
    }
    
    private func setup() {
        cancellable = setDocument.sortsPublisher.sink { [weak self] sorts in
            self?.updateRows(with: sorts)
        }
    }
    
    private func updateRows(with sorts: [SetSort]) {
        rows = sorts.enumerated().map { index, sort in
            SetSortRowConfiguration(
                id: "\(sort.relationDetails.id)_\(index)",
                title: sort.relationDetails.name,
                subtitle: sort.typeTitle(),
                iconAsset: sort.relationDetails.format.iconAsset,
                onTap: { [weak self] in
                    self?.rowTapped(sort.relationDetails.id, index: index)
                }
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
            AnytypeAnalytics.instance().logChangeSortValue(
                type: setSort.sort.type.stringValue,
                objectType: setDocument.analyticsType
            )
        }
    }
}
