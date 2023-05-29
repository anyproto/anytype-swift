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
        indexSet.forEach { [weak self] deleteIndex in
            guard let self, deleteIndex < self.setDocument.filters.count else { return }
            let filter = self.setDocument.filters[deleteIndex]
            Task {
                try await dataviewService.removeFilters([filter.filter.id], viewId: self.setDocument.activeView.id)
                AnytypeAnalytics.instance().logFilterRemove(objectType: self.setDocument.analyticsType)
            }
        }
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
        showFilterSearch(with: filter)
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
    
    func showFilterSearch(with filter: SetFilter) {
        router.showFilterSearch(filter: filter) { [weak self] updatedFilter in
            guard let self else { return }
            Task {
                if filter.filter.id.isNotEmpty {
                    try await self.dataviewService.replaceFilter(
                        filter.filter.id,
                        with: updatedFilter.filter,
                        viewId: self.setDocument.activeView.id
                    )
                    if filter.filter.condition != updatedFilter.filter.condition {
                        AnytypeAnalytics.instance().logChangeFilterValue(
                            condition: updatedFilter.filter.condition.stringValue,
                            objectType: self.setDocument.analyticsType
                        )
                    }
                } else {
                    try await self.dataviewService.addFilter(
                        updatedFilter.filter,
                        viewId: self.setDocument.activeView.id
                    )
                    AnytypeAnalytics.instance().logAddFilter(
                        condition: updatedFilter.filter.condition.stringValue,
                        objectType: self.setDocument.analyticsType
                    )
                }
            }
        }
    }
}
