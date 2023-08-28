import SwiftUI

@MainActor
protocol SetFiltersDateCoordinatorOutput: AnyObject {
    func onFiltersDaysTap(title: String, text: String, onTextChanged: @escaping (String) -> Void)
}

@MainActor
final class SetFiltersDateCoordinatorViewModel: ObservableObject, SetFiltersDateCoordinatorOutput {
    @Published var filtersDaysData: FiltersDateData?
    
    private let filter: SetFilter
    
    // TODO: Needs refactoring
    private weak var setSelectionModel: SetFiltersSelectionViewModel?
    
    private let completion: (SetFiltersDate) -> Void
    private let setFiltersDateViewModuleAssembly: SetFiltersDateViewModuleAssemblyProtocol
    private let setTextViewModuleAssembly: SetTextViewModuleAssemblyProtocol
    
    init(
        filter: SetFilter,
        setSelectionModel: SetFiltersSelectionViewModel?,
        completion: @escaping (SetFiltersDate) -> Void,
        setFiltersDateViewModuleAssembly: SetFiltersDateViewModuleAssemblyProtocol,
        setTextViewModuleAssembly: SetTextViewModuleAssemblyProtocol
    ) {
        self.filter = filter
        self.setSelectionModel = setSelectionModel
        self.completion = completion
        self.setFiltersDateViewModuleAssembly = setFiltersDateViewModuleAssembly
        self.setTextViewModuleAssembly = setTextViewModuleAssembly
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
        filtersDaysData = FiltersDateData(
            title: title,
            text: text,
            onTextChanged: onTextChanged
        )
    }
    
    func filtersDaysView(_ data: FiltersDateData) -> AnyView {
        setTextViewModuleAssembly.make(
            title: data.title,
            text: data.text,
            onTextChanged: data.onTextChanged
        )
    }
}

extension SetFiltersDateCoordinatorViewModel {
    struct FiltersDateData: Identifiable {
        let id = UUID()
        let title: String
        let text: String
        let onTextChanged: (String) -> Void
    }
}
