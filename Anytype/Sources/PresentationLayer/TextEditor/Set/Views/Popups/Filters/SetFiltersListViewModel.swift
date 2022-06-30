import Foundation
import SwiftUI
import BlocksModels
import FloatingPanel

final class SetFiltersListViewModel: ObservableObject {
    
    private let setModel: EditorSetViewModel
    private let service: DataviewServiceProtocol
    private let router: EditorRouterProtocol
    
    var rows: [SetFilterRowConfiguration] {
        setModel.filters.map {
            SetFilterRowConfiguration(
                id: $0.metadata.id,
                name: $0.metadata.name,
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
