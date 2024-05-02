import Foundation

final class ModulesDI: ModulesDIProtocol {
    
    private let uiHelpersDI: UIHelpersDIProtocol
    private let widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol
    
    init(uiHelpersDI: UIHelpersDIProtocol, widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol) {
        self.uiHelpersDI = uiHelpersDI
        self.widgetsSubmoduleDI = widgetsSubmoduleDI
    }
    
    // MARK: - ModulesDIProtocol
    
    func createObject() -> CreateObjectModuleAssemblyProtocol {
        return CreateObjectModuleAssembly()
    }
    
    func homeWidgets() -> HomeWidgetsModuleAssemblyProtocol {
        return HomeWidgetsModuleAssembly(
            uiHelpersDI: uiHelpersDI,
            widgetsSubmoduleDI:  widgetsSubmoduleDI
        )
    }
    
    func widgetObjectList() -> WidgetObjectListModuleAssemblyProtocol {
        return WidgetObjectListModuleAssembly(uiHelpersDI: uiHelpersDI)
    }
}
