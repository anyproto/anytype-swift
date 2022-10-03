import Foundation
import SwiftUI
import BlocksModels
import Combine

final class SetSortsListViewModel: ObservableObject {
    @Published var rows: [SetSortRowConfiguration] = []
    
    private let setModel: EditorSetViewModel
    private var cancellable: Cancellable?
    
    private let service: DataviewServiceProtocol
    private let router: EditorRouterProtocol
    
    init(
        setModel: EditorSetViewModel,
        service: DataviewServiceProtocol,
        router: EditorRouterProtocol)
    {
        self.setModel = setModel
        self.service = service
        self.router = router
        self.setup()
    }
    
}

extension SetSortsListViewModel {
    
    // MARK: - Routing
    
    func addButtonTapped() {
        let excludeRelations: [RelationMetadata] = setModel.sorts.map { $0.metadata }
        router.showRelationSearch(
            relations: setModel.activeViewRelations(excludeRelations: excludeRelations))
        { [weak self] key in
            self?.addNewSort(with: key)
        }
    }
    
    func rowTapped(_ id: String) {
        guard let setSort = setModel.sorts.first(where: { $0.id == id }) else {
            return
        }
        let view = CheckPopupView(viewModel: SetSortTypesListViewModel(
            sort: setSort,
            onSelect: { [weak self] sort in
                let newSetSort = SetSort(
                    metadata: setSort.metadata,
                    sort: sort
                )
                self?.updateSorts(with: newSetSort)
            })
        )
        router.presentSheet(
            AnytypePopup(
                contentView: view
            )
        )
    }
    
    // MARK: - Actions
    
    func delete(_ indexSet: IndexSet) {
        var sorts = setModel.sorts
        sorts.remove(atOffsets: indexSet)
        updateView(with: sorts)
    }
    
    func move(from: IndexSet, to: Int) {
        var sorts = setModel.sorts
        sorts.move(fromOffsets: from, toOffset: to)
        updateView(with: sorts)
    }
    
    func addNewSort(with key: String) {
        var dataviewSorts = setModel.sorts.map { $0.sort }
        dataviewSorts.append(
            DataviewSort(
                relationKey: key,
                type: .asc
            )
        )
        updateView(with: dataviewSorts)
    }
    
    private func setup() {
        cancellable = setModel.$sorts.sink { [weak self] sorts in
            self?.updateRows(with: sorts)
        }
    }
    
    private func updateRows(with sorts: [SetSort]) {
        rows = sorts.map {
            SetSortRowConfiguration(
                id: $0.id,
                title: $0.metadata.name,
                subtitle: $0.typeTitle(),
                iconAsset: $0.metadata.format.iconAsset
            )
        }
    }
    
    private func updateSorts(with setSort: SetSort) {
        let sorts: [SetSort] = setModel.sorts.map { sort in
            if sort.metadata.key == setSort.metadata.key {
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
        let newView = setModel.activeView.updated(sorts: dataviewSorts)
        service.updateView(newView)
    }
}
