import SwiftUI

@MainActor
protocol SetFiltersDateCoordinatorOutput: AnyObject {
    func onFiltersDaysTap(title: String, text: String, onTextChanged: @escaping (String) -> Void)
}

@MainActor
final class SetFiltersDateCoordinatorViewModel: ObservableObject, SetFiltersDateCoordinatorOutput {
    @Published var filtersDaysData: SetTextViewData?
    
    private let filter: SetFilter
    
    // TODO: Needs refactoring
    private weak var setSelectionModel: SetFiltersSelectionViewModel?
    
    private let setFiltersDateViewModuleAssembly: SetFiltersDateViewModuleAssemblyProtocol
    private let completion: (SetFiltersDate) -> Void
    
    init(
        filter: SetFilter,
        setSelectionModel: SetFiltersSelectionViewModel?,
        setFiltersDateViewModuleAssembly: SetFiltersDateViewModuleAssemblyProtocol,
        completion: @escaping (SetFiltersDate) -> Void
    ) {
        self.filter = filter
        self.setSelectionModel = setSelectionModel
        self.setFiltersDateViewModuleAssembly = setFiltersDateViewModuleAssembly
        self.completion = completion
    }
    
    func list() -> AnyView {
        setFiltersDateViewModuleAssembly.make(
            filter: filter,
            selectionModel: setSelectionModel,
            onApplyDate: completion
        )
    }
    
    // MARK: - SetViewSettingsNavigationOutput
    
    func onFiltersDaysTap(title: String, text: String, onTextChanged: @escaping (String) -> Void) {
        filtersDaysData = SetTextViewData(
            title: title,
            text: text,
            onTextChanged: onTextChanged
        )
    }
}
