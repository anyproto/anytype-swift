import SwiftUI

@MainActor
protocol SetViewSettingsCoordinatorOutput: AnyObject {
    func onLayoutTap()
    func onRelationsTap()
    func onFiltersTap()
    func onSortsTap()
}

@MainActor
@Observable
final class SetViewSettingsCoordinatorViewModel: SetViewSettingsCoordinatorOutput {
    var showLayouts = false
    var showRelations = false
    var showFilters = false
    var showSorts = false

    @ObservationIgnored
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
