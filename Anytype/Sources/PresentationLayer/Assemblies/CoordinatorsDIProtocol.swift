import Foundation

protocol CoordinatorsDIProtocol: AnyObject {
    func relationValue() -> RelationValueCoordinatorAssemblyProtocol
    func templates() -> TemplatesCoordinatorAssemblyProtocol
    func editorPage() -> EditorPageCoordinatorAssemblyProtocol
    func linkToObject() -> LinkToObjectCoordinatorAssemblyProtocol
    func objectSettings() -> ObjectSettingsCoordinatorAssemblyProtocol
    func addNewRelation() -> AddNewRelationCoordinatorAssemblyProtocol
    func homeWidgets() -> HomeWidgetsCoordinatorAssemblyProtocol
    func createWidget() -> CreateWidgetCoordinatorAssemblyProtocol
    
    // Rename
    @MainActor
    func application() -> ApplicationCoordinator
    // Split to modules
    @MainActor
    func windowManager() -> WindowManager
    
    // Now like a coordinator. Migrate to isolated modules
    func browser() -> EditorBrowserAssembly
    func editor() -> EditorAssembly
    func homeViewAssemby() -> HomeViewAssembly
}
