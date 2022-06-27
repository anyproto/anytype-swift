import Foundation
import SwiftUI
import BlocksModels
import FloatingPanel

final class SetFiltersListViewModel: ObservableObject {
    
    private let setModel: EditorSetViewModel
    private let service: DataviewServiceProtocol
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
                )
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

extension SetFiltersListViewModel {
    
    // MARK: - Actions
    
    func rowTapped(_ filter: SetFilter) {}
    
    func delete(_ indexSet: IndexSet) {
        var filters = setModel.filters
        filters.remove(atOffsets: indexSet)
        updateView(with: filters)
    }
    
    private func updateView(with filters: [SetFilter]) {
        let dataviewFilters = filters.map { $0.filter }
        updateView(with: dataviewFilters)
    }
    
    private func updateView(with dataviewFilters: [DataviewFilter]) {
        let newView = setModel.activeView.updated(filters: dataviewFilters)
        service.updateView(newView)
    }
}
