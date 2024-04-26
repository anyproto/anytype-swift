import Foundation

protocol CoordinatorsDIProtocol: AnyObject {
    func relationValue() -> RelationValueCoordinatorAssemblyProtocol
    func templates() -> TemplatesCoordinatorAssemblyProtocol
    func linkToObject() -> LinkToObjectCoordinatorAssemblyProtocol
    func objectSettings() -> ObjectSettingsCoordinatorAssemblyProtocol
    func addNewRelation() -> AddNewRelationCoordinatorAssemblyProtocol
    func home() -> HomeCoordinatorAssemblyProtocol
    func createWidget() -> CreateWidgetCoordinatorAssemblyProtocol
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
    func editorPage() -> EditorPageCoordinatorAssemblyProtocol
    func setObjectCreationSettings() -> SetObjectCreationSettingsCoordinatorAssemblyProtocol
    func initial() -> InitialCoordinatorAssemblyProtocol
    func spaceSwitch() -> SpaceSwitchCoordinatorAssemblyProtocol
    func setObjectCreation() -> SetObjectCreationCoordinatorAssemblyProtocol
    func serverConfiguration() -> ServerConfigurationCoordinatorAssemblyProtocol
    func sharingTip() -> SharingTipCoordinatorProtocol
    func galleryInstallation() -> GalleryInstallationCoordinatorAssemblyProtocol
    func notificationCoordinator() -> NotificationCoordinatorProtocol // Global coordinator without root view
    func selectRelationList() -> SelectRelationListCoordinatorAssemblyProtocol
    func objectRelationList() -> ObjectRelationListCoordinatorAssemblyProtocol
    func spaceShare() -> SpaceShareCoordinatorAssemblyProtocol
    
    // Now like a coordinator. Migrate to isolated modules
    func editorPageModule() -> EditorPageModuleAssemblyProtocol
    func editorSetModule() -> EditorSetModuleAssemblyProtocol
}
