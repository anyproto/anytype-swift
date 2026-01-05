import SwiftUI
import Services

@MainActor
@Observable
final class SetFiltersSelectionHeaderViewModel {
    var headerConfiguration: SetFiltersSelectionHeaderConfiguration

    @ObservationIgnored
    private var filter: SetFilter
    @ObservationIgnored
    private weak var output: (any SetFiltersSelectionCoordinatorOutput)?
    @ObservationIgnored
    private let onConditionChanged: (DataviewFilter.Condition) -> Void
    
    init(
        data: SetFiltersSelectionHeaderData,
        output: (any SetFiltersSelectionCoordinatorOutput)?
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
