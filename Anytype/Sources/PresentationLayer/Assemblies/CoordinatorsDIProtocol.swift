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
    func editorBrowser() -> EditorBrowserModuleAssemblyProtocol
    func application() -> ApplicationCoordinatorAssemblyProtocol
    func settings() -> SettingsCoordinatorAssemblyProtocol
    func authorization() -> AuthCoordinatorAssemblyProtocol
    func joinFlow() -> JoinFlowCoordinatorAssemblyProtocol
    func loginFlow() -> LoginFlowCoordinatorAssemblyProtocol
    func spaceSettings() -> SpaceSettingsCoordinatorAssemblyProtocol
    func setViewSettings() -> SetViewSettingsCoordinatorAssemblyProtocol
    func setSortsList() -> SetSortsListCoordinatorAssemblyProtocol
    func setFiltersDate() -> SetFiltersDateCoordinatorAssemblyProtocol
    func setFiltersSelection() -> SetFiltersSelectionCoordinatorAssemblyProtocol
    func setFiltersList() -> SetFiltersListCoordinatorAssemblyProtocol
    func setLayoutSettings() -> SetLayoutSettingsCoordinatorAssemblyProtocol
    func setRelations() -> SetRelationsCoordinatorAssemblyProtocol
    func setViewPicker() -> SetViewPickerCoordinatorAssemblyProtocol
    func share() -> ShareCoordinatorAssemblyProtocol
    func editor() -> EditorCoordinatorAssemblyProtocol
    func editorSet() -> EditorSetCoordinatorAssemblyProtocol
    func editorPage() -> EditorNewPageCoordinatorAssemblyProtocol
    func setObjectCreationSettings() -> SetObjectCreationSettingsCoordinatorAssemblyProtocol
    
    // Now like a coordinator. Migrate to isolated modules
    func browser() -> EditorBrowserAssembly
    func editorLegacy() -> EditorAssembly
    
    func editorPageModule() -> EditorPageModuleAssemblyProtocol
    func editorSetModule() -> EditorSetModuleAssemblyProtocol
}
