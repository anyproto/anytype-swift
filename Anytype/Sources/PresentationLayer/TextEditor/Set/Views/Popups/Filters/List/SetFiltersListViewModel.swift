import Foundation
import SwiftUI
import BlocksModels
import FloatingPanel
import Combine

final class SetFiltersListViewModel: ObservableObject {
    @Published var rows: [SetFilterRowConfiguration] = []
    
    private let setDocument: SetDocumentProtocol
    private var cancellable: Cancellable?
    
    private let dataviewService: DataviewServiceProtocol
    private let router: EditorSetRouterProtocol
    private let relationFilterBuilder = RelationFilterBuilder()
    
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

extension SetFiltersListViewModel {
    
    // MARK: - Actions
    
    func addButtonTapped() {
        let relationsDetails = setDocument.activeViewRelations(excludeRelations: [])
        router.showRelationSearch(relationsDetails: relationsDetails) { [weak self] relationDetails in
            guard let filter = self?.makeSetFilter(with: relationDetails) else {
                return
            }
            self?.showFilterSearch(with: filter)
        }
    }
    
    func delete(_ indexSet: IndexSet) {
        var filters = setDocument.filters
        filters.remove(atOffsets: indexSet)
        updateView(with: filters)
    }
    
    // MARK: - Private methods
    
    private func setup() {
        cancellable = setDocument.filtersPublisher.sink { [weak self] filters in
            self?.updateRows(with: filters)
        }
    }
    
    private func updateRows(with filters: [SetFilter]) {
        rows = filters.enumerated().map { index, filter in
            SetFilterRowConfiguration(
                id: "\(filter.relationDetails.id)_\(index)",
                title: filter.relationDetails.name,
                subtitle: filter.conditionString,
                iconAsset: filter.relationDetails.format.iconAsset,
                type: type(for: filter),
                hasValues: filter.filter.condition.hasValues,
                onTap: { [weak self] in
                    self?.rowTapped(filter.relationDetails.id, index: index)
                }
            )
        }
    }
    
    private func rowTapped(_ id: String, index: Int) {
        guard let filter = setDocument.filters[safe: index], filter.id == id  else {
            return
        }
        showFilterSearch(with: filter, index: index)
    }

    private func updateView(with filters: [SetFilter]) {
        let dataviewFilters = filters.map { $0.filter }
        updateView(with: dataviewFilters)
    }
    
    private func updateView(with dataviewFilters: [DataviewFilter]) {
        let newView = setDocument.activeView.updated(filters: dataviewFilters)
        Task {
            try await dataviewService.updateView(newView)
        }
    }
    
    private func makeSetFilter(with relationDetails: RelationDetails) -> SetFilter? {
        guard let filteredDetails = setDocument.activeViewRelations(excludeRelations: []).first(where: { $0.id == relationDetails.id }) else {
            return nil
        }
        return SetFilter(
            relationDetails: filteredDetails,
            filter: DataviewFilter(
                relationKey: filteredDetails.key,
                condition: SetFilter.defaultCondition(for: filteredDetails),
                value: [String]().protobufValue
            )
        )
    }
    
    private func handleFilterSearch(_ updatedFilter: SetFilter, index: Int?) {
        var filters = setDocument.filters.map { $0.filter }
        
        if let index = index,
            let filter = filters[safe: index],
           filter.relationKey == filter.relationKey {
            filters[index] = updatedFilter.filter
        } else {
            filters.append(updatedFilter.filter)
        }
        updateView(with: filters)
    }
    
    private func type(for filter: SetFilter) -> SetFilterRowType {
        switch filter.relationDetails.format {
        case .date:
            return .date(
                relationFilterBuilder.dateString(
                    for: filter.filter
                )
            )
        default:
            return .relation(
                relationFilterBuilder.relation(
                    relationDetails: filter.relationDetails,
                    filter: filter.filter
                )
            )
        }
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
