import Foundation
import UIKit

final class CoordinatorsDI: CoordinatorsDIProtocol {
    
    private let serviceLocator: ServiceLocator
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, modulesDI: ModulesDIProtocol, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - CoordinatorsDIProtocol
    
    func legacyRelationValue() -> LegacyRelationValueCoordinatorAssembly {
        return LegacyRelationValueCoordinatorAssembly(
            modulesDI: modulesDI,
            uiHelpersDI: uiHelpersDI
        )
    }
    
    func relationValue() -> RelationValueCoordinatorAssemblyProtocol {
        return RelationValueCoordinatorAssembly(
            coordinatorsID: self,
            modulesDI: modulesDI, 
            uiHelpersDI: uiHelpersDI
        )
    }
    
    func relationsList() -> RelationsListCoordinatorAssemblyProtocol {
        RelationsListCoordinatorAssembly(
            coordinatorsID: self,
            modulesDI: modulesDI,
            serviceLocator: serviceLocator
        )
    }
    
    func templates() -> TemplatesCoordinatorAssemblyProtocol {
        return TemplatesCoordinatorAssembly(serviceLocator: serviceLocator, coordinatorsDI: self)
    }

    func objectSettings() -> ObjectSettingsCoordinatorAssemblyProtocol {
        return ObjectSettingsCoordinatorAssembly(modulesDI: modulesDI, uiHelpersDI: uiHelpersDI, coordinatorsDI: self, serviceLocator: serviceLocator)
    }
    
    func addNewRelation() -> AddNewRelationCoordinatorAssemblyProtocol {
        return AddNewRelationCoordinatorAssembly(uiHelpersDI: uiHelpersDI, modulesDI: modulesDI)
    }
    
    @MainActor
    func home() -> HomeCoordinatorAssemblyProtocol {
        return HomeCoordinatorAssembly(
            coordinatorsID: self,
            modulesDI: modulesDI,
            serviceLocator: serviceLocator,
            uiHelpersDI: uiHelpersDI
        )
    }

    func application() -> ApplicationCoordinatorAssemblyProtocol {
        return ApplicationCoordinatorAssembly(coordinatorsDI: self, uiHelpersDI: uiHelpersDI)
    }
    
    func settings() -> SettingsCoordinatorAssemblyProtocol {
        return SettingsCoordinatorAssembly(modulesDI: modulesDI, uiHelpersDI: uiHelpersDI, coordinatorsDI: self, serviceLocator: serviceLocator)
    }
    
    func spaceSettings() -> SpaceSettingsCoordinatorAssemblyProtocol {
        return SpaceSettingsCoordinatorAssembly(modulesDI: modulesDI, serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI, coordinatorsDI: self)
    }
    
    func setViewSettings() -> SetViewSettingsCoordinatorAssemblyProtocol {
        return SetViewSettingsCoordinatorAssembly(modulesDI: modulesDI, coordinatorsDI: self)
    }
    
    func setFiltersSelection() -> SetFiltersSelectionCoordinatorAssemblyProtocol {
        SetFiltersSelectionCoordinatorAssembly(modulesDI: modulesDI, coordinatorsDI: self)
    }
    
    func setFiltersList() -> SetFiltersListCoordinatorAssemblyProtocol {
        SetFiltersListCoordinatorAssembly(modulesDI: modulesDI, coordinatorsDI: self)
    }
    
    func setRelations() -> SetRelationsCoordinatorAssemblyProtocol {
        SetRelationsCoordinatorAssembly(modulesDI: modulesDI, coordinatorsDI: self)
    }
    
    func setViewPicker() -> SetViewPickerCoordinatorAssemblyProtocol {
        SetViewPickerCoordinatorAssembly(modulesDI: modulesDI, coordinatorsDI: self)
    }

    func editor() -> EditorCoordinatorAssemblyProtocol {
        EditorCoordinatorAssembly(coordinatorsID: self, modulesDI: modulesDI)
    }

    func editorSet() -> EditorSetCoordinatorAssemblyProtocol {
        EditorSetCoordinatorAssembly(coordinatorsID: self, modulesDI: modulesDI, serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }

    func editorPage() -> EditorPageCoordinatorAssemblyProtocol {
        EditorPageCoordinatorAssembly(coordinatorsID: self, modulesDI: modulesDI, serviceLocator: serviceLocator)
    }

    func setObjectCreationSettings() -> SetObjectCreationSettingsCoordinatorAssemblyProtocol {
        SetObjectCreationSettingsCoordinatorAssembly(modulesDI: modulesDI, uiHelpersDI: uiHelpersDI, coordinatorsDI: self)
    }

    func editorPageModule() -> EditorPageModuleAssemblyProtocol {
        EditorPageModuleAssembly(serviceLocator: serviceLocator, coordinatorsDI: self, modulesDI: modulesDI, uiHelpersDI: uiHelpersDI)
    }

    func editorSetModule() -> EditorSetModuleAssemblyProtocol {
        EditorSetModuleAssembly(serviceLocator: serviceLocator, coordinatorsDI: self, modulesDI: modulesDI, uiHelpersDI: uiHelpersDI)
    }

    func spaceSwitch() -> SpaceSwitchCoordinatorAssemblyProtocol {
        SpaceSwitchCoordinatorAssembly(modulesDI: modulesDI, coordinatorsDI: self)
    }
    
    func setObjectCreation() -> SetObjectCreationCoordinatorAssemblyProtocol {
        SetObjectCreationCoordinatorAssembly(
            serviceLocator: serviceLocator,
            modulesDI: modulesDI,
            uiHelpersDI: uiHelpersDI,
            coordinatorsDI: self
        )
    }
    
    func sharingTip() -> SharingTipCoordinatorProtocol {
        SharingTipCoordinator(
            navigationContext: uiHelpersDI.commonNavigationContext()
        )
    }
    
    func typeSearchForNewObject() -> TypeSearchForNewObjectCoordinatorAssemblyProtocol {
        TypeSearchForNewObjectCoordinatorAssembly(
            serviceLocator: serviceLocator,
            modulesDI: modulesDI
        )
    }
}
