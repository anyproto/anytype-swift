import SwiftUI

@MainActor
protocol SetViewSettingsCoordinatorOutput: AnyObject {
    func onRelationsTap()
    func onFiltersTap()
    func onSortsTap()
}

@MainActor
final class SetViewSettingsCoordinatorViewModel: ObservableObject, SetViewSettingsCoordinatorOutput {
    @Published var showRelations = false
    @Published var showFilters = false
    @Published var showSorts = false
    
    private let setViewSettingsListModuleAssembly: SetViewSettingsListModuleAssemblyProtocol
    
    init(setViewSettingsListModuleAssembly: SetViewSettingsListModuleAssemblyProtocol) {
        self.setViewSettingsListModuleAssembly = setViewSettingsListModuleAssembly
    }
    
    func list() -> AnyView {
        setViewSettingsListModuleAssembly.make(output: self)
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
