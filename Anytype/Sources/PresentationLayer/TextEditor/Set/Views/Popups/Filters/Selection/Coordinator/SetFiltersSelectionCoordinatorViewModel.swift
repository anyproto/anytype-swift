import SwiftUI
import Services

@MainActor
protocol SetFiltersSelectionCoordinatorOutput: AnyObject {
    func onConditionTap(filter: SetFilter, completion: @escaping (DataviewFilter.Condition) -> Void)
}

@MainActor
@Observable
final class SetFiltersSelectionCoordinatorViewModel: SetFiltersSelectionCoordinatorOutput {
    var filterConditions: SetFilterConditions?

    @ObservationIgnored
    let data: SetFiltersSelectionData
    @ObservationIgnored
    let contentViewBuilder: SetFiltersContentViewBuilder
    
    init(
        spaceId: String,
        filter: SetFilter,
        completion: @escaping (SetFilter) -> Void
    ) {
        self.data = SetFiltersSelectionData(filter: filter, onApply: completion)
        self.contentViewBuilder = SetFiltersContentViewBuilder(
            spaceId: spaceId,
            filter: filter
        )
    }
    
    // MARK: - SetFiltersSelectionCoordinatorOutput
    
    func onConditionTap(filter: SetFilter, completion: @escaping (DataviewFilter.Condition) -> Void) {
        filterConditions = SetFilterConditions(
            filter: filter,
            completion: completion
        )
    }    
}
