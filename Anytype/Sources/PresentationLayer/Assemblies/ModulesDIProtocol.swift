import Foundation

protocol ModulesDIProtocol: AnyObject {
    func relationValue() -> RelationValueModuleAssemblyProtocol
    func textRelationEditing() -> TextRelationEditingModuleAssemblyProtocol
    func createObject() -> CreateObjectModuleAssemblyProtocol
    func newSearch() -> NewSearchModuleAssemblyProtocol
    func homeWidgets() -> HomeWidgetsModuleAssemblyProtocol
    func widgetObjectList() -> WidgetObjectListModuleAssemblyProtocol
    func dashboardAlerts() -> DashboardAlertsAssemblyProtocol
    func homeBottomNavigationPanel() -> HomeBottomNavigationPanelModuleAssemblyProtocol
    func objectTypeSearch() -> ObjectTypeSearchModuleAssemblyProtocol
}
