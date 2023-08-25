import SwiftUI
import Services

@MainActor
final class SetFiltersSelectionHeaderViewModel: ObservableObject {
    @Published var headerConfiguration: SetFiltersSelectionHeaderConfiguration
    
    private var filter: SetFilter
    private weak var output: SetFiltersSelectionCoordinatorOutput?
    
    init(
        filter: SetFilter,
        output: SetFiltersSelectionCoordinatorOutput?
    ) {
        self.filter = filter
        self.output = output
        self.headerConfiguration = Self.headerConfiguration(with: filter)
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
    }
    
    private func showFilterConditions() {
        output?.onConditionTap { [weak self] condition in
            self?.updateFilter(with: condition)
        }
    }
}
