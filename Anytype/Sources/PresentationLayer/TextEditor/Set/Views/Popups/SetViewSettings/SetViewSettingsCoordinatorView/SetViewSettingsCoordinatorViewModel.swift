import SwiftUI

@MainActor
protocol SetViewSettingsCoordinatorOutput: AnyObject {
    func onDefaultObjectTap()
    func onLayoutTap()
    func onRelationsTap()
    func onFiltersTap()
    func onSortsTap()
}

@MainActor
final class SetViewSettingsCoordinatorViewModel: ObservableObject, SetViewSettingsCoordinatorOutput {
    @Published var showObjects = false
    @Published var showLayouts = false
    @Published var showRelations = false
    @Published var showFilters = false
    @Published var showSorts = false
    
    private let setDocument: SetDocumentProtocol
    private let setViewSettingsListModuleAssembly: SetViewSettingsListModuleAssemblyProtocol
    private let setSortsListCoordinatorAssembly: SetSortsListCoordinatorAssemblyProtocol
    
    init(
        setDocument: SetDocumentProtocol,
        setViewSettingsListModuleAssembly: SetViewSettingsListModuleAssemblyProtocol,
        setSortsListCoordinatorAssembly: SetSortsListCoordinatorAssemblyProtocol
    ) {
        self.setDocument = setDocument
        self.setViewSettingsListModuleAssembly = setViewSettingsListModuleAssembly
        self.setSortsListCoordinatorAssembly = setSortsListCoordinatorAssembly
    }
    
    func list() -> AnyView {
        setViewSettingsListModuleAssembly.make(output: self)
    }
    
    // MARK: - SetViewSettingsNavigationOutput
    
    func onDefaultObjectTap() {
        showObjects.toggle()
    }
    
    func onLayoutTap() {
        showLayouts.toggle()
    }
    
    func onRelationsTap() {
        showRelations.toggle()
    }
    
    func onFiltersTap() {
        showFilters.toggle()
    }
    
    // MARK: - Sorts
    
    func onSortsTap() {
        showSorts.toggle()
    }
    
    func setSortsList() -> AnyView {
        setSortsListCoordinatorAssembly.make(with: setDocument)
    }
}
