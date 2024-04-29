import Foundation

final class ModulesDI: ModulesDIProtocol {
    
    private let uiHelpersDI: UIHelpersDIProtocol
    private let widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol
    
    init(uiHelpersDI: UIHelpersDIProtocol, widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol) {
        self.uiHelpersDI = uiHelpersDI
        self.widgetsSubmoduleDI = widgetsSubmoduleDI
    }
    
    // MARK: - ModulesDIProtocol
    
    func relationValue() -> RelationValueModuleAssemblyProtocol {
        return RelationValueModuleAssembly(modulesDI: self, uiHelpersDI: uiHelpersDI)
    }
    
    func textRelationEditing() -> TextRelationEditingModuleAssemblyProtocol {
        TextRelationEditingModuleAssembly(uiHelpersDI: uiHelpersDI)
    }
    
    func createObject() -> CreateObjectModuleAssemblyProtocol {
        return CreateObjectModuleAssembly()
    }
    
    func newSearch() -> NewSearchModuleAssemblyProtocol {
        return NewSearchModuleAssembly(uiHelpersDI: uiHelpersDI)
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

    func objectTypeSearch() -> ObjectTypeSearchModuleAssemblyProtocol {
        ObjectTypeSearchModuleAssembly(uiHelpersDI: uiHelpersDI)
    }
}
