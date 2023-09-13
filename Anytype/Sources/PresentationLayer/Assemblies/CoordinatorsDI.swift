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
    
    func relationValue() -> RelationValueCoordinatorAssemblyProtocol {
        return RelationValueCoordinatorAssembly(
            serviceLocator: serviceLocator,
            modulesDI: modulesDI,
            uiHelpersDI: uiHelpersDI
        )
    }
    
    func templates() -> TemplatesCoordinatorAssemblyProtocol {
        return TemplatesCoordinatorAssembly(serviceLocator: serviceLocator, coordinatorsDI: self)
    }
    
    func editorPage() -> EditorPageCoordinatorAssemblyProtocol {
        return EditorPageCoordinatorAssembly(
            serviceLocator: serviceLocator,
            modulesDI: modulesDI,
            coordinatorsID: self
        )
    }
    
    func linkToObject() -> LinkToObjectCoordinatorAssemblyProtocol {
        return LinkToObjectCoordinatorAssembly(
            serviceLocator: serviceLocator,
            modulesDI: modulesDI,
            coordinatorsID: self,
            uiHelopersDI: uiHelpersDI
        )
    }
    
    func objectSettings() -> ObjectSettingsCoordinatorAssemblyProtocol {
        return ObjectSettingsCoordinatorAssembly(modulesDI: modulesDI, uiHelpersDI: uiHelpersDI, coordinatorsDI: self, serviceLocator: serviceLocator)
    }
    
    func addNewRelation() -> AddNewRelationCoordinatorAssemblyProtocol {
        return AddNewRelationCoordinatorAssembly(uiHelpersDI: uiHelpersDI, modulesDI: modulesDI)
    }
    
    @MainActor
    func homeWidgets() -> HomeWidgetsCoordinatorAssemblyProtocol {
        return HomeWidgetsCoordinatorAssembly(
            coordinatorsID: self,
            modulesDI: modulesDI,
            serviceLocator: serviceLocator,
            uiHelpersDI: uiHelpersDI
        )
    }
    
    func createWidget() -> CreateWidgetCoordinatorAssemblyProtocol {
        return CreateWidgetCoordinatorAssembly(
            modulesDI: modulesDI,
            serviceLocator: serviceLocator,
            uiHelpersDI: uiHelpersDI
        )
    }
    
    func browser() -> EditorBrowserAssembly {
        return EditorBrowserAssembly(coordinatorsDI: self, serviceLocator: serviceLocator)
    }
    
    func editor() -> EditorAssembly {
        return EditorAssembly(serviceLocator: serviceLocator, coordinatorsDI: self, modulesDI: modulesDI, uiHelpersDI: uiHelpersDI)
    }
    
    func editorBrowser() -> EditorBrowserModuleAssemblyProtocol {
        return EditorBrowserModuleAssembly(uiHelpersDI: uiHelpersDI, coordinatorsID: self)
    }
    
    func application() -> ApplicationCoordinatorAssemblyProtocol {
        return ApplicationCoordinatorAssembly(serviceLocator: serviceLocator, coordinatorsDI: self, uiHelpersDI: uiHelpersDI)
    }
    
    func settings() -> SettingsCoordinatorAssemblyProtocol {
        return SettingsCoordinatorAssembly(modulesDI: modulesDI, uiHelpersDI: uiHelpersDI, serviceLocator: serviceLocator)
    }
    
    func authorization() -> AuthCoordinatorAssemblyProtocol {
        return AuthCoordinatorAssembly(modulesDI: modulesDI, coordinatorsID: self, uiHelpersDI: uiHelpersDI)
    }
    
    func joinFlow() -> JoinFlowCoordinatorAssemblyProtocol {
        return JoinFlowCoordinatorAssembly(modulesDI: modulesDI)
    }
    
    func loginFlow() -> LoginFlowCoordinatorAssemblyProtocol {
        return LoginFlowCoordinatorAssembly(modulesDI: modulesDI, uiHelpersDI: uiHelpersDI)
    }
    
    func legacyAuthViewAssembly() -> LegacyAuthViewAssembly {
        return LegacyAuthViewAssembly(serviceLocator: serviceLocator)
    }
    
    func setViewSettings() -> SetViewSettingsCoordinatorAssemblyProtocol {
        return SetViewSettingsCoordinatorAssembly(modulesDI: modulesDI, coordinatorsDI: self)
    }
    
    func setSortsList() -> SetSortsListCoordinatorAssemblyProtocol {
        return SetSortsListCoordinatorAssembly(modulesDI: modulesDI)
    }
    
    func setFiltersDate() -> SetFiltersDateCoordinatorAssemblyProtocol {
        SetFiltersDateCoordinatorAssembly(modulesDI: modulesDI)
    }
    
    func setFiltersSelection() -> SetFiltersSelectionCoordinatorAssemblyProtocol {
        SetFiltersSelectionCoordinatorAssembly(modulesDI: modulesDI, coordinatorsDI: self)
    }
    
    func setFiltersList() -> SetFiltersListCoordinatorAssemblyProtocol {
        SetFiltersListCoordinatorAssembly(modulesDI: modulesDI, coordinatorsDI: self)
    }
    
    func setLayoutSettings() -> SetLayoutSettingsCoordinatorAssemblyProtocol {
        SetLayoutSettingsCoordinatorAssembly(modulesDI: modulesDI)
    }
    
    func setRelations() -> SetRelationsCoordinatorAssemblyProtocol {
        SetRelationsCoordinatorAssembly(modulesDI: modulesDI, coordinatorsDI: self)
    }
    
    func setViewPicker() -> SetViewPickerCoordinatorAssemblyProtocol {
        SetViewPickerCoordinatorAssembly(modulesDI: modulesDI)
    }
}
