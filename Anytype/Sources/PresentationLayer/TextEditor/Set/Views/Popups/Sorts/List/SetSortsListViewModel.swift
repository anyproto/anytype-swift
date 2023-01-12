import Foundation
import SwiftUI
import BlocksModels
import Combine

final class SetSortsListViewModel: ObservableObject {
    @Published var rows: [SetSortRowConfiguration] = []
    
    private let setDocument: SetDocumentProtocol
    private var cancellable: Cancellable?
    
    private let service: DataviewServiceProtocol
    private let router: EditorSetRouterProtocol
    
    init(
        setDocument: SetDocumentProtocol,
        service: DataviewServiceProtocol,
        router: EditorSetRouterProtocol)
    {
        self.setDocument = setDocument
        self.service = service
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
        var sorts = setDocument.sorts
        sorts.remove(atOffsets: indexSet)
        updateView(with: sorts)
    }
    
    func move(from: IndexSet, to: Int) {
        var sorts = setDocument.sorts
        sorts.move(fromOffsets: from, toOffset: to)
        updateView(with: sorts)
    }
    
    func addNewSort(with relation: RelationDetails) {
        var dataviewSorts = setDocument.sorts.map { $0.sort }
        dataviewSorts.append(
            DataviewSort(
                relationKey: relation.key,
                type: .asc
            )
        )
        updateView(with: dataviewSorts)
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
        let sorts: [SetSort] = setDocument.sorts.map { sort in
            if sort.relationDetails.key == setSort.relationDetails.key {
                return setSort
            } else {
                return sort
            }
        }
        updateView(with: sorts)
    }
    
    private func updateView(with sorts: [SetSort]) {
        let dataviewSorts = sorts.map { $0.sort }
        updateView(with: dataviewSorts)
    }
    
    private func updateView(with dataviewSorts: [DataviewSort]) {
        let newView = setDocument.activeView.updated(sorts: dataviewSorts)
        Task {
            try await service.updateView(newView)
        }
    }
}
