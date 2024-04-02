import SwiftUI
import Services

@MainActor
final class SetFiltersSelectionHeaderViewModel: ObservableObject {
    @Published var headerConfiguration: SetFiltersSelectionHeaderConfiguration
    
    private var filter: SetFilter
    private weak var output: SetFiltersSelectionCoordinatorOutput?
    private let onConditionChanged: (DataviewFilter.Condition) -> Void
    
    init(
        data: SetFiltersSelectionHeaderData,
        output: SetFiltersSelectionCoordinatorOutput?
    ) {
        self.filter = data.filter
        self.onConditionChanged = data.onConditionChanged
        self.headerConfiguration = Self.headerConfiguration(with: filter)
        self.output = output
    }
    
    func conditionTapped() {
        showFilterConditions()
    }
    
    // MARK: - Private methods
    
    private static func headerConfiguration(with filter: SetFilter) -> SetFiltersSelectionHeaderConfiguration {
        SetFiltersSelectionHeaderConfiguration(
            id: filter.id,
            title: filter.relationDetails.name,
            condition: filter.conditionString ?? "",
            iconAsset: filter.relationDetails.format.iconAsset
        )
    }
    
    private func updateFilter(with condition: DataviewFilter.Condition) {
        filter = filter.updated(
            filter: filter.filter.updated(
                condition: condition
            )
        )
        headerConfiguration = Self.headerConfiguration(with: filter)
        onConditionChanged(condition)
    }
    
    private func showFilterConditions() {
        output?.onConditionTap(filter: filter) { [weak self] condition in
            self?.updateFilter(with: condition)
        }
    }
}
