import Foundation

protocol ModulesDIProtocol: AnyObject {
    func relationValue() -> RelationValueModuleAssemblyProtocol
    func textRelationEditing() -> TextRelationEditingModuleAssemblyProtocol
    func objectLayoutPicker() -> ObjectLayoutPickerModuleAssemblyProtocol
    func createObject() -> CreateObjectModuleAssemblyProtocol
    func newSearch() -> NewSearchModuleAssemblyProtocol
    func newRelation() -> NewRelationModuleAssemblyProtocol
    func homeWidgets() -> HomeWidgetsModuleAssemblyProtocol
    func widgetObjectList() -> WidgetObjectListModuleAssemblyProtocol
    func settingsAppearance() -> SettingsAppearanceModuleAssemblyProtocol
    func dashboardAlerts() -> DashboardAlertsAssemblyProtocol
    func setViewSettingsList() -> SetViewSettingsListModuleAssemblyProtocol
    func homeBottomNavigationPanel() -> HomeBottomNavigationPanelModuleAssemblyProtocol
    func deleteAccount() -> DeleteAccountModuleAssemblyProtocol
    func objectTypeSearch() -> ObjectTypeSearchModuleAssemblyProtocol
}
