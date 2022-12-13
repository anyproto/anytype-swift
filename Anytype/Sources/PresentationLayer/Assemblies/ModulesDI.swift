import Foundation

final class ModulesDI: ModulesDIProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - ModulesDIProtocol
    
    var relationValue: RelationValueModuleAssemblyProtocol {
        return RelationValueModuleAssembly(modulesDI: self, serviceLocator: serviceLocator)
    }
    
    var relationsList: RelationsListModuleAssemblyProtocol {
        return RelationsListModuleAssembly()
    }
    
    var undoRedo: UndoRedoModuleAssemblyProtocol {
        return UndoRedoModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    var objectLayoutPicker: ObjectLayoutPickerModuleAssemblyProtocol {
        return ObjectLayoutPickerModuleAssembly(serviceLocator: serviceLocator)
    }
    
    var objectCoverPicker: ObjectCoverPickerModuleAssemblyProtocol {
        return ObjectCoverPickerModuleAssembly(serviceLocator: serviceLocator)
    }
    
    var objectIconPicker: ObjectIconPickerModuleAssemblyProtocol {
        return ObjectIconPickerModuleAssembly(serviceLocator: serviceLocator)
    }
    
    var objectSetting: ObjectSettingModuleAssemblyProtocol {
        return ObjectSettingModuleAssembly(serviceLocator: serviceLocator)
    }
    
    var search: SearchModuleAssemblyProtocol {
        return SearchModuleAssembly(serviceLocator: serviceLocator)
    }
    
    var createObject: CreateObjectModuleAssemblyProtocol {
        return CreateObjectModuleAssembly(serviceLocator: serviceLocator)
    }

    var codeLanguageList: CodeLanguageListModuleAssemblyProtocol {
        return CodeLanguageListModuleAssembly(serviceLocator: serviceLocator)
    }
    
    var newSearch: NewSearchModuleAssemblyProtocol {
        return NewSearchModuleAssembly(uiHelpersDI: uiHelpersDI)
    }
}
