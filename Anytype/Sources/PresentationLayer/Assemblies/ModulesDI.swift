import Foundation

final class ModulesDI: ModulesDIProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    private let widgetsDI: WidgetsDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol, widgetsDI: WidgetsDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
        self.widgetsDI = widgetsDI
    }
    
    // MARK: - ModulesDIProtocol
    
    func relationValue() -> RelationValueModuleAssemblyProtocol {
        return RelationValueModuleAssembly(modulesDI: self, serviceLocator: serviceLocator)
    }
    
    func relationsList() -> RelationsListModuleAssemblyProtocol {
        return RelationsListModuleAssembly()
    }
    
    func undoRedo() -> UndoRedoModuleAssemblyProtocol {
        return UndoRedoModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func objectLayoutPicker() -> ObjectLayoutPickerModuleAssemblyProtocol {
        return ObjectLayoutPickerModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func objectCoverPicker() -> ObjectCoverPickerModuleAssemblyProtocol {
        return ObjectCoverPickerModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func objectIconPicker() -> ObjectIconPickerModuleAssemblyProtocol {
        return ObjectIconPickerModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func objectSetting() -> ObjectSettingModuleAssemblyProtocol {
        return ObjectSettingModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func search() -> SearchModuleAssemblyProtocol {
        return SearchModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func createObject() -> CreateObjectModuleAssemblyProtocol {
        return CreateObjectModuleAssembly(serviceLocator: serviceLocator)
    }

    func codeLanguageList() -> CodeLanguageListModuleAssemblyProtocol {
        return CodeLanguageListModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func newSearch() -> NewSearchModuleAssemblyProtocol {
        return NewSearchModuleAssembly(uiHelpersDI: uiHelpersDI)
    }
    
    func newRelation() -> NewRelationModuleAssemblyProtocol {
        return NewRelationModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func homeWidgets() -> HomeWidgetsModuleAssemblyProtocol {
        return HomeWidgetsModuleAssembly(
            serviceLocator: serviceLocator,
            uiHelpersDI: uiHelpersDI,
            widgetsDI:  widgetsDI
        )
    }
    
    func textIconPicker() -> TextIconPickerModuleAssemblyProtocol {
        return TextIconPickerModuleAssembly(serviceLocator: serviceLocator)
    }
}
