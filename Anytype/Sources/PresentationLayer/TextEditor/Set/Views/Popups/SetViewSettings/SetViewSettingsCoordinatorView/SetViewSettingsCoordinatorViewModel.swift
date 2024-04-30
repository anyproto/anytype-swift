import SwiftUI

@MainActor
protocol SetViewSettingsCoordinatorOutput: AnyObject {
    func onLayoutTap()
    func onRelationsTap()
    func onFiltersTap()
    func onSortsTap()
}

@MainActor
final class SetViewSettingsCoordinatorViewModel: ObservableObject, SetViewSettingsCoordinatorOutput {
    @Published var showLayouts = false
    @Published var showRelations = false
    @Published var showFilters = false
    @Published var showSorts = false
    
    let data: SetSettingsData
    
    init(data: SetSettingsData) {
        self.data = data
    }
    
    // MARK: - SetViewSettingsCoordinatorOutput
    
    // MARK: - Layout
    
    func onLayoutTap() {
        showLayouts.toggle()
    }
    
    // MARK: - Relations
    
    func onRelationsTap() {
        showRelations.toggle()
    }
    
    // MARK: - Filters
    
    func onFiltersTap() {
        showFilters.toggle()
    }
    
    // MARK: - Sorts
    
    func onSortsTap() {
        showSorts.toggle()
    }
}
