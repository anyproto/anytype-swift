import Foundation

protocol ModulesDIProtocol: AnyObject {
    func relationValue() -> RelationValueModuleAssemblyProtocol
    func relationsList() -> RelationsListModuleAssemblyProtocol
    func textRelationEditing() -> TextRelationEditingModuleAssemblyProtocol
    func undoRedo() -> UndoRedoModuleAssemblyProtocol
    func objectLayoutPicker() -> ObjectLayoutPickerModuleAssemblyProtocol
    func objectIconPicker() -> ObjectIconPickerModuleAssemblyProtocol
    func objectSetting() -> ObjectSettingModuleAssemblyProtocol
    func createObject() -> CreateObjectModuleAssemblyProtocol
    func newSearch() -> NewSearchModuleAssemblyProtocol
    func newRelation() -> NewRelationModuleAssemblyProtocol
    func homeWidgets() -> HomeWidgetsModuleAssemblyProtocol
    func textIconPicker() -> TextIconPickerModuleAssemblyProtocol
    func widgetObjectList() -> WidgetObjectListModuleAssemblyProtocol
    func settingsAppearance() -> SettingsAppearanceModuleAssemblyProtocol
    func dashboardAlerts() -> DashboardAlertsAssemblyProtocol
    func authKey() -> KeyPhraseViewModuleAssemblyProtocol
    func authCreatingSoul() -> CreatingSoulViewModuleAssemblyProtocol
    func setObjectCreationSettings() -> SetObjectCreationSettingsModuleAssemblyProtocol
    func setViewSettingsList() -> SetViewSettingsListModuleAssemblyProtocol
    func setFiltersListModule() -> SetFiltersListModuleAssemblyProtocol
    func setViewSettingsImagePreview() -> SetViewSettingsImagePreviewModuleAssemblyProtocol
    func setLayoutSettingsView() -> SetLayoutSettingsViewAssemblyProtocol
    func setViewSettingsGroupByView() -> SetViewSettingsGroupByModuleAssemblyProtocol
    func setRelationsView() -> SetRelationsViewModuleAssemblyProtocol
    func setViewPicker() -> SetViewPickerModuleAssemblyProtocol
    func homeBottomNavigationPanel() -> HomeBottomNavigationPanelModuleAssemblyProtocol
    func deleteAccount() -> DeleteAccountModuleAssemblyProtocol
    func objectTypeSearch() -> ObjectTypeSearchModuleAssemblyProtocol
}
