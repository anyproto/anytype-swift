import Foundation
import SwiftUI
import BlocksModels
import FloatingPanel

final class SetSortsListViewModel: ObservableObject {
    
    private let setModel: EditorSetViewModel
    private let service: DataviewServiceProtocol
    private let router: EditorRouterProtocol
    
    var rows: [SetSortRowConfiguration] {
        setModel.sorts.map {
            SetSortRowConfiguration(
                id: $0.id,
                title: $0.metadata.name,
                subtitle: $0.typeTitle(),
                iconName: $0.metadata.format.iconName
            )
        }
    }
    
    init(
        setModel: EditorSetViewModel,
        service: DataviewServiceProtocol,
        router: EditorRouterProtocol)
    {
        self.setModel = setModel
        self.service = service
        self.router = router
    }
    
}

extension SetSortsListViewModel {
    
    // MARK: - Routing
    
    func addButtonTapped() {
        router.showRelationSearch(relations: setModel.relations) { [weak self] key in
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
