import SwiftUI
import Services

@MainActor
protocol SetFiltersSelectionCoordinatorOutput: AnyObject {
    func onConditionTap(filter: SetFilter, completion: @escaping (DataviewFilter.Condition) -> Void)
}

@MainActor
final class SetFiltersSelectionCoordinatorViewModel: ObservableObject, SetFiltersSelectionCoordinatorOutput {
    @Published var filterConditions: SetFilterConditions?
    
    private let filter: SetFilter
    private let setFiltersSelectionViewModuleAssembly: SetFiltersSelectionViewModuleAssemblyProtocol
    private let contentViewBuilder: SetFiltersContentViewBuilder
    private let completion: (SetFilter) -> Void
    
    init(
        spaceId: String,
        filter: SetFilter,
        setFiltersSelectionHeaderModuleAssembly: SetFiltersSelectionHeaderModuleAssemblyProtocol,
        setFiltersSelectionViewModuleAssembly: SetFiltersSelectionViewModuleAssemblyProtocol,
        setFiltersDateCoordinatorAssembly: SetFiltersDateCoordinatorAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        completion: @escaping (SetFilter) -> Void
    ) {
        self.filter = filter
        self.setFiltersSelectionViewModuleAssembly = setFiltersSelectionViewModuleAssembly
        self.contentViewBuilder = SetFiltersContentViewBuilder(
            spaceId: spaceId,
            filter: filter,
            setFiltersSelectionHeaderModuleAssembly: setFiltersSelectionHeaderModuleAssembly,
            setFiltersDateCoordinatorAssembly: setFiltersDateCoordinatorAssembly,
            newSearchModuleAssembly: newSearchModuleAssembly
        )
        self.completion = completion
    }
    
    func list() -> AnyView {
        setFiltersSelectionViewModuleAssembly.make(
            with: filter,
            output: self,
            contentViewBuilder: contentViewBuilder,
            completion: completion
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
