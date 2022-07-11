import Foundation
import SwiftUI
import BlocksModels
import FloatingPanel

final class SetFiltersListViewModel: ObservableObject {
    
    private let setModel: EditorSetViewModel
    private let dataviewService: DataviewServiceProtocol
    private let router: EditorRouterProtocol
    private let relationFilterBuilder = RelationFilterBuilder()
    
    var rows: [SetFilterRowConfiguration] {
        setModel.filters.enumerated().map { index, filter in
            SetFilterRowConfiguration(
                id: "\(filter.metadata.id)_\(index)",
                title: filter.metadata.name,
                subtitle: filter.conditionString,
                iconName: filter.metadata.format.iconName,
                relation: relationFilterBuilder.relation(
                    metadata: filter.metadata,
                    filter: filter.filter
                ),
                onTap: { [weak self] in
                    self?.rowTapped(filter.metadata.id, index: index)
                }
            )
        }
    }
    
    init(
        setModel: EditorSetViewModel,
        dataviewService: DataviewServiceProtocol,
        router: EditorRouterProtocol)
    {
        self.setModel = setModel
        self.dataviewService = dataviewService
        self.router = router
    }
    
}

extension SetFiltersListViewModel {
    
    // MARK: - Actions
    
    func addButtonTapped() {
        router.showRelationSearch(relations: setModel.relations) { [weak self] id in
            guard let filter = self?.makeSetFilter(with: id) else {
                return
            }
            self?.showFilterSearch(with: filter)
        }
    }
    
    func delete(_ indexSet: IndexSet) {
        var filters = setModel.filters
        filters.remove(atOffsets: indexSet)
        updateView(with: filters)
    }
    
    // MARK: - Private methods
    
    private func rowTapped(_ id: String, index: Int) {
        guard let filter = setModel.filters[safe: index], filter.id == id  else {
            return
        }
        showFilterSearch(with: filter, index: index)
    }

    private func updateView(with filters: [SetFilter]) {
        let dataviewFilters = filters.map { $0.filter }
        updateView(with: dataviewFilters)
    }
    
    private func updateView(with dataviewFilters: [DataviewFilter]) {
        let newView = setModel.activeView.updated(filters: dataviewFilters)
        dataviewService.updateView(newView)
    }
    
    private func makeSetFilter(with id: String) -> SetFilter? {
        guard let metadata = setModel.relations.first(where: { $0.id == id }) else {
            return nil
        }
        return SetFilter(
            metadata: metadata,
            filter: DataviewFilter(
                relationKey: id,
                condition: SetFilter.defaultCondition(for: metadata),
                value: [String]().protobufValue
            )
        )
    }
    
    private func handleFilterSearch(_ updatedFilter: SetFilter, index: Int?) {
        var filters = setModel.filters.map { $0.filter }
        
        if let index = index,
            let filter = filters[safe: index],
           filter.relationKey == filter.relationKey {
            filters[index] = updatedFilter.filter
        } else {
            filters.append(updatedFilter.filter)
        }
        updateView(with: filters)
    }
    
    // MARK: - Routing
    
    private func showFilterSearch(with filter: SetFilter, index: Int? = nil) {
        router.showFilterSearch(
            filter: filter,
            onApply: { [weak self] updatedFilter in
                self?.handleFilterSearch(updatedFilter, index: index)
            }
        )
    }
}
