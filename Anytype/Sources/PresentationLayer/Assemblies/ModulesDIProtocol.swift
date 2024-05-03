import Foundation

protocol ModulesDIProtocol: AnyObject {
    func createObject() -> CreateObjectModuleAssemblyProtocol
    func homeWidgets() -> HomeWidgetsModuleAssemblyProtocol
    func widgetObjectList() -> WidgetObjectListModuleAssemblyProtocol
}
