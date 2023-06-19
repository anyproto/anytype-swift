import Foundation

protocol ModulesDIProtocol: AnyObject {
    func relationValue() -> RelationValueModuleAssemblyProtocol
    func relationsList() -> RelationsListModuleAssemblyProtocol
    func undoRedo() -> UndoRedoModuleAssemblyProtocol
    func objectLayoutPicker() -> ObjectLayoutPickerModuleAssemblyProtocol
    func objectCoverPicker() -> ObjectCoverPickerModuleAssemblyProtocol
    func objectIconPicker() -> ObjectIconPickerModuleAssemblyProtocol
    func objectSetting() -> ObjectSettingModuleAssemblyProtocol
    func search() -> SearchModuleAssemblyProtocol
    func createObject() -> CreateObjectModuleAssemblyProtocol
    func codeLanguageList() -> CodeLanguageListModuleAssemblyProtocol
    func newSearch() -> NewSearchModuleAssemblyProtocol
    func newRelation() -> NewRelationModuleAssemblyProtocol
    func homeWidgets() -> HomeWidgetsModuleAssemblyProtocol
    func textIconPicker() -> TextIconPickerModuleAssemblyProtocol
    func widgetType() -> WidgetTypeModuleAssemblyProtocol
    func widgetObjectList() -> WidgetObjectListModuleAssemblyProtocol
    func settingsAppearance() -> SettingsAppearanceModuleAssemblyProtocol
    func wallpaperPicker() -> WallpaperPickerModuleAssemblyProtocol
    func about() -> AboutModuleAssemblyProtocol
    func personalization() -> PersonalizationModuleAssemblyProtocol
    func keychainPhrase() -> KeychainPhraseModuleAssemblyProtocol
    func dashboardAlerts() -> DashboardAlertsAssemblyProtocol
    func settings() -> SettingsModuleAssemblyProtocol
    func debugMenu() -> DebugMenuModuleAssemblyProtocol
    func settingsAccount() -> SettingsAccountModuleAssemblyProtocol
    func fileStorage() -> FileStorageModuleAssemblyProtocol
    
    func authorization() -> AuthModuleAssemblyProtocol
    func joinFlow() -> JoinFlowModuleAssemblyProtocol
    func login() -> LoginViewModuleAssemblyProtocol
    func authVoid() -> VoidViewModuleAssemblyProtocol
    func authKey() -> KeyPhraseViewModuleAssemblyProtocol
    func authSoul() -> SoulViewModuleAssemblyProtocol
    func authCreatingSoul() -> CreatingSoulViewModuleAssemblyProtocol
}
