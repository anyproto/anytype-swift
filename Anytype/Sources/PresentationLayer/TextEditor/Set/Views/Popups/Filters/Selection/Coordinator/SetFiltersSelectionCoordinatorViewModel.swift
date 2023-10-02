import SwiftUI
import Services

@MainActor
protocol SetFiltersSelectionCoordinatorOutput: AnyObject {
    func onConditionTap(filter: SetFilter, completion: @escaping (DataviewFilter.Condition) -> Void)
}

@MainActor
final class SetFiltersSelectionCoordinatorViewModel: ObservableObject, SetFiltersSelectionCoordinatorOutput {
    @Published var filterConditions: FilterConditions?
    
    private let filter: SetFilter
    private let setFiltersSelectionViewModuleAssembly: SetFiltersSelectionViewModuleAssemblyProtocol
    private let setFilterConditionsModuleAssembly: SetFilterConditionsModuleAssemblyProtocol
    private let contentViewBuilder: SetFiltersContentViewBuilder
    private let completion: (SetFilter) -> Void
    
    init(
        spaceId: String,
        filter: SetFilter,
        setFiltersSelectionHeaderModuleAssembly: SetFiltersSelectionHeaderModuleAssemblyProtocol,
        setFiltersSelectionViewModuleAssembly: SetFiltersSelectionViewModuleAssemblyProtocol,
        setFiltersDateCoordinatorAssembly: SetFiltersDateCoordinatorAssemblyProtocol,
        setFilterConditionsModuleAssembly: SetFilterConditionsModuleAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        setFiltersTextViewModuleAssembly: SetFiltersTextViewModuleAssemblyProtocol,
        setFiltersCheckboxViewModuleAssembly: SetFiltersCheckboxViewModuleAssemblyProtocol,
        completion: @escaping (SetFilter) -> Void
    ) {
        self.filter = filter
        self.setFiltersSelectionViewModuleAssembly = setFiltersSelectionViewModuleAssembly
        self.setFilterConditionsModuleAssembly = setFilterConditionsModuleAssembly
        self.contentViewBuilder = SetFiltersContentViewBuilder(
            spaceId: spaceId,
            filter: filter,
            setFiltersSelectionHeaderModuleAssembly: setFiltersSelectionHeaderModuleAssembly,
            setFiltersDateCoordinatorAssembly: setFiltersDateCoordinatorAssembly,
            newSearchModuleAssembly: newSearchModuleAssembly,
            setFiltersTextViewModuleAssembly: setFiltersTextViewModuleAssembly,
            setFiltersCheckboxViewModuleAssembly: setFiltersCheckboxViewModuleAssembly
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
        filterConditions = FilterConditions(
            filter: filter,
            completion: completion
        )
    }
    
    func setFilterConditions(data: FilterConditions) -> AnyView {
        setFilterConditionsModuleAssembly.make(
            with: data.filter,
            completion: data.completion
        )
    }
    
}

extension SetFiltersSelectionCoordinatorViewModel {
    struct FilterConditions: Identifiable {
        var id: String { filter.id }
        let filter: SetFilter
        let completion: (DataviewFilter.Condition) -> Void
    }
}
