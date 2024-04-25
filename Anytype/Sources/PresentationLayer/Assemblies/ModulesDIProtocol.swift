import Foundation

protocol ModulesDIProtocol: AnyObject {
    func relationValue() -> RelationValueModuleAssemblyProtocol
    func textRelationEditing() -> TextRelationEditingModuleAssemblyProtocol
    func createObject() -> CreateObjectModuleAssemblyProtocol
    func newSearch() -> NewSearchModuleAssemblyProtocol
    func homeWidgets() -> HomeWidgetsModuleAssemblyProtocol
    func widgetObjectList() -> WidgetObjectListModuleAssemblyProtocol
    func objectTypeSearch() -> ObjectTypeSearchModuleAssemblyProtocol
}
