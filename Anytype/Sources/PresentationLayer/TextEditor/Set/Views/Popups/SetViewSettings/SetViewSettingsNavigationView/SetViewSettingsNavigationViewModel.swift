import SwiftUI

protocol SetViewSettingsNavigationOutput: AnyObject {
    func onRelationsTap()
    func onFiltersTap()
    func onSortsTap()
}

final class SetViewSettingsNavigationViewModel: ObservableObject, SetViewSettingsNavigationOutput {
    @Published var showRelations = false
    @Published var showFilters = false
    @Published var showSorts = false
    
    
    func list() -> AnyView {
        SetViewSettingsList(
            model: SetViewSettingsListModel(output: self)
        ).eraseToAnyView()
    }
    
    // MARK: - SetViewSettingsNavigationOutput
    
    func onRelationsTap() {
        showRelations.toggle()
    }
    
    func onFiltersTap() {
        showFilters.toggle()
    }
    
    func onSortsTap() {
        showSorts.toggle()
    }
}
