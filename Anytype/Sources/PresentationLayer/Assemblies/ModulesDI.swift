import Foundation

final class ModulesDI: ModulesDIProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    private let widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol, widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
        self.widgetsSubmoduleDI = widgetsSubmoduleDI
    }
    
    // MARK: - ModulesDIProtocol
    
    func relationValue() -> RelationValueModuleAssemblyProtocol {
        return RelationValueModuleAssembly(modulesDI: self, serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func relationsList() -> RelationsListModuleAssemblyProtocol {
        return RelationsListModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func textRelationEditing() -> TextRelationEditingModuleAssemblyProtocol {
        TextRelationEditingModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func objectLayoutPicker() -> ObjectLayoutPickerModuleAssemblyProtocol {
        return ObjectLayoutPickerModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func objectIconPicker() -> ObjectIconPickerModuleAssemblyProtocol {
        return ObjectIconPickerModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func createObject() -> CreateObjectModuleAssemblyProtocol {
        return CreateObjectModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func newSearch() -> NewSearchModuleAssemblyProtocol {
        return NewSearchModuleAssembly(uiHelpersDI: uiHelpersDI, serviceLocator: serviceLocator)
    }
    
    func newRelation() -> NewRelationModuleAssemblyProtocol {
        return NewRelationModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func homeWidgets() -> HomeWidgetsModuleAssemblyProtocol {
        return HomeWidgetsModuleAssembly(
            serviceLocator: serviceLocator,
            uiHelpersDI: uiHelpersDI,
            widgetsSubmoduleDI:  widgetsSubmoduleDI
        )
    }
    
    func textIconPicker() -> TextIconPickerModuleAssemblyProtocol {
        return TextIconPickerModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func widgetObjectList() -> WidgetObjectListModuleAssemblyProtocol {
        return WidgetObjectListModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func settingsAppearance() -> SettingsAppearanceModuleAssemblyProtocol {
        return SettingsAppearanceModuleAssembly(uiHelpersDI: uiHelpersDI)
    }
    
    func dashboardAlerts() -> DashboardAlertsAssemblyProtocol {
        return DashboardAlertsAssembly(uiHelpersDI: uiHelpersDI)
    }
    
    func setObjectCreationSettings() -> SetObjectCreationSettingsModuleAssemblyProtocol {
        return SetObjectCreationSettingsModuleAssembly(serviceLocator: serviceLocator, uiHelperDI: uiHelpersDI)
    }
    
    func setViewSettingsList() -> SetViewSettingsListModuleAssemblyProtocol {
        return SetViewSettingsListModuleAssembly(serviceLocator: serviceLocator)
    }

    func homeBottomNavigationPanel() -> HomeBottomNavigationPanelModuleAssemblyProtocol {
        HomeBottomNavigationPanelModuleAssembly(serviceLocator: serviceLocator)
    }

    func deleteAccount() -> DeleteAccountModuleAssemblyProtocol {
        DeleteAccountModuleAssembly(serviceLocator: serviceLocator)
    }

    func objectTypeSearch() -> ObjectTypeSearchModuleAssemblyProtocol {
        ObjectTypeSearchModuleAssembly(uiHelpersDI: uiHelpersDI, serviceLocator: serviceLocator)
    }
}
