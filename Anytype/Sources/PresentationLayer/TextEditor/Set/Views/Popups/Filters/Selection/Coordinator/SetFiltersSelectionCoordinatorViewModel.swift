import SwiftUI
import Services

@MainActor
protocol SetFiltersSelectionCoordinatorOutput: AnyObject {
    func onConditionTap(completion: @escaping (DataviewFilter.Condition) -> Void)
}

@MainActor
final class SetFiltersSelectionCoordinatorViewModel: ObservableObject, SetFiltersSelectionCoordinatorOutput {
    @Published var filterConditions: FilterConditions?
    
    private let filter: SetFilter
    private let completion: (SetFilter) -> Void
    private let setFiltersSelectionHeaderModuleAssembly: SetFiltersSelectionHeaderModuleAssemblyProtocol
    private let setFiltersSelectionViewModuleAssembly: SetFiltersSelectionViewModuleAssemblyProtocol
    private let setFilterConditionsModuleAssembly: SetFilterConditionsModuleAssemblyProtocol
    private let contentViewBuilder: SetFiltersContentViewBuilder
    
    init(
        filter: SetFilter,
        completion: @escaping (SetFilter) -> Void,
        setFiltersSelectionHeaderModuleAssembly: SetFiltersSelectionHeaderModuleAssemblyProtocol,
        setFiltersSelectionViewModuleAssembly: SetFiltersSelectionViewModuleAssemblyProtocol,
        setFiltersDateCoordinatorAssembly: SetFiltersDateCoordinatorAssemblyProtocol,
        setFilterConditionsModuleAssembly: SetFilterConditionsModuleAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    ) {
        self.filter = filter
        self.completion = completion
        self.setFiltersSelectionHeaderModuleAssembly = setFiltersSelectionHeaderModuleAssembly
        self.setFiltersSelectionViewModuleAssembly = setFiltersSelectionViewModuleAssembly
        self.setFilterConditionsModuleAssembly = setFilterConditionsModuleAssembly
        self.contentViewBuilder = SetFiltersContentViewBuilder(
            filter: filter,
            setFiltersDateCoordinatorAssembly: setFiltersDateCoordinatorAssembly,
            newSearchModuleAssembly: newSearchModuleAssembly
        )
    }
    
    func header() -> AnyView {
        setFiltersSelectionHeaderModuleAssembly.make(
            filter: filter,
            output: self
        )
    }
    
    func list() -> AnyView {
        setFiltersSelectionViewModuleAssembly.make(
            with: filter,
            contentViewBuilder: contentViewBuilder,
            completion: completion
        )
    }
    
    func isCompactPresentationMode() -> Bool {
        contentViewBuilder.compactPresentationMode()
    }
    
    // MARK: - SetFiltersSelectionCoordinatorOutput
    
    func onConditionTap(completion: @escaping (DataviewFilter.Condition) -> Void) {
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
