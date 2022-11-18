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
        return RelationValueModuleAssembly()
    }
    
    var undoRedo: UndoRedoModuleAssemblyProtocol {
        return UndoRedoModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    var objectLayoutPicker: ObjectLayoutPickerModuleAssemblyProtocol {
        return ObjectLayoutPickerModuleAssembly(serviceLocator: serviceLocator)
    }
    
    var objectCoverPicker: ObjectCoverPickerModuleAssemblyProtocol {
        return ObjectCoverPickerModuleAssembly()
    }
    
    var objectIconPicker: ObjectIconPickerModuleAssemblyProtocol {
        return ObjectIconPickerModuleAssembly()
    }
    
    var objectSetting: ObjectSettingModuleAssemblyProtocol {
        return ObjectSettingModuleAssembly()
    }
}
