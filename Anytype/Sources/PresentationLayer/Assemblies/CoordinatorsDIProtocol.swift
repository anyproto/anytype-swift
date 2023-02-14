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
    func editorBrowser() -> EditorBrowserCoordinatorAssemblyProtocol
    func application() -> ApplicationCoordinatorAssemblyProtocol
    
    // Now like a coordinator. Migrate to isolated modules
    func browser() -> EditorBrowserAssembly
    func editor() -> EditorAssembly
    func homeViewAssemby() -> HomeViewAssembly
}
