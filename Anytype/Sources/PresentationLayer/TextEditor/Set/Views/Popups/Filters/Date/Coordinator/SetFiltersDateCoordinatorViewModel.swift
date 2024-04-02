import SwiftUI

@MainActor
protocol SetFiltersDateCoordinatorOutput: AnyObject {
    func onFiltersDaysTap(title: String, text: String, onTextChanged: @escaping (String) -> Void)
}

@MainActor
final class SetFiltersDateCoordinatorViewModel: ObservableObject, SetFiltersDateCoordinatorOutput {
    @Published var filtersDaysData: SetTextViewData?
    
    let data: SetFiltersDateViewData
    
    // TODO: Needs refactoring
    weak var setSelectionModel: SetFiltersSelectionViewModel?
    
    init(
        data: SetFiltersDateViewData,
        setSelectionModel: SetFiltersSelectionViewModel?
    ) {
        self.data = data
        self.setSelectionModel = setSelectionModel
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
