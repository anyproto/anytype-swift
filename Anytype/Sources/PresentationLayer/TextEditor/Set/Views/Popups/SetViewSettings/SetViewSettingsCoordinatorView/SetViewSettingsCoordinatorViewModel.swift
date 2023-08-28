import SwiftUI
import Services

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
    private let subscriptionDetailsStorage: ObjectDetailsStorage
    private let setViewSettingsListModuleAssembly: SetViewSettingsListModuleAssemblyProtocol
    private let setFiltersListCoordinatorAssembly: SetFiltersListCoordinatorAssemblyProtocol
    private let setSortsListCoordinatorAssembly: SetSortsListCoordinatorAssemblyProtocol
    
    init(
        setDocument: SetDocumentProtocol,
        subscriptionDetailsStorage: ObjectDetailsStorage,
        setViewSettingsListModuleAssembly: SetViewSettingsListModuleAssemblyProtocol,
        setFiltersListCoordinatorAssembly: SetFiltersListCoordinatorAssemblyProtocol,
        setSortsListCoordinatorAssembly: SetSortsListCoordinatorAssemblyProtocol
    ) {
        self.setDocument = setDocument
        self.subscriptionDetailsStorage = subscriptionDetailsStorage
        self.setViewSettingsListModuleAssembly = setViewSettingsListModuleAssembly
        self.setFiltersListCoordinatorAssembly = setFiltersListCoordinatorAssembly
        self.setSortsListCoordinatorAssembly = setSortsListCoordinatorAssembly
    }
    
    func list() -> AnyView {
        setViewSettingsListModuleAssembly.make(setDocument: setDocument, output: self)
    }
    
    // MARK: - SetViewSettingsCoordinatorOutput
    
    func onDefaultObjectTap() {
        showObjects.toggle()
    }
    
    func onLayoutTap() {
        showLayouts.toggle()
    }
    
    func onRelationsTap() {
        showRelations.toggle()
    }
    
    // MARK: - Filters
    
    func onFiltersTap() {
        showFilters.toggle()
    }
    
    func setFiltersList() -> AnyView {
        setFiltersListCoordinatorAssembly.make(
            with: setDocument,
            subscriptionDetailsStorage: subscriptionDetailsStorage
        )
    }
    
    // MARK: - Sorts
    
    func onSortsTap() {
        showSorts.toggle()
    }
    
    func setSortsList() -> AnyView {
        setSortsListCoordinatorAssembly.make(with: setDocument)
    }
}
