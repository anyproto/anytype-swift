import SwiftUI
import Services

@MainActor
protocol SetFiltersSelectionCoordinatorOutput: AnyObject {
    func onConditionTap(filter: SetFilter, completion: @escaping (DataviewFilter.Condition) -> Void)
}

@MainActor
final class SetFiltersSelectionCoordinatorViewModel: ObservableObject, SetFiltersSelectionCoordinatorOutput {
    @Published var filterConditions: SetFilterConditions?
    
    let data: SetFiltersSelectionData
    let contentViewBuilder: SetFiltersContentViewBuilder
    
    init(
        spaceId: String,
        filter: SetFilter,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        completion: @escaping (SetFilter) -> Void
    ) {
        self.data = SetFiltersSelectionData(filter: filter, onApply: completion)
        self.contentViewBuilder = SetFiltersContentViewBuilder(
            spaceId: spaceId,
            filter: filter,
            newSearchModuleAssembly: newSearchModuleAssembly
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
