import Foundation

protocol WidgetsDIProtocol {
    func homeWidgetsRegistry(
        stateManager: HomeWidgetsStateManagerProtocol,
        widgetOutput: CommonWidgetModuleOutput?
    ) -> HomeWidgetsRegistryProtocol
    func objectTreeWidgetModuleAssembly() -> ObjectTreeWidgetModuleAssemblyProtocol
    func setWidgetModuleAssembly() -> SetWidgetModuleAssemblyProtocol
    func favoriteWidgetModuleAssembly() -> FavoriteWidgetModuleAssemblyProtocol
    func recentWidgetModuleAssembly() -> RecentWidgetModuleAssemblyProtocol
    func bottomPanelProviderAssembly() -> HomeBottomPanelProviderAssemblyProtocol
    func bottomPanelModuleAssembly() -> HomeBottomPanelModuleAssemblyProtocol
}

final class WidgetsDI: WidgetsDIProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - WidgetsDIProtocol
    
    func homeWidgetsRegistry(
        stateManager: HomeWidgetsStateManagerProtocol,
        widgetOutput: CommonWidgetModuleOutput?
    ) -> HomeWidgetsRegistryProtocol {
        return HomeWidgetsRegistry(
            treeWidgetProviderAssembly: ObjectTreeWidgetProviderAssembly(widgetsDI: self, output: widgetOutput),
            setWidgetProviderAssembly: SetWidgetProviderAssembly(widgetsDI: self, output: widgetOutput),
            favoriteWidgetProviderAssembly: FavoriteWidgetProviderAssembly(widgetsDI: self, output: widgetOutput),
            recentWidgetProviderAssembly: RecentWidgetProviderAssembly(widgetsDI: self, output: widgetOutput),
            stateManager: stateManager,
            objectDetailsStorage: serviceLocator.objectDetailsStorage()
        )
    }
    
    func objectTreeWidgetModuleAssembly() -> ObjectTreeWidgetModuleAssemblyProtocol {
        return ObjectTreeWidgetModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func setWidgetModuleAssembly() -> SetWidgetModuleAssemblyProtocol {
        return SetWidgetModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func favoriteWidgetModuleAssembly() -> FavoriteWidgetModuleAssemblyProtocol {
        return FavoriteWidgetModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func recentWidgetModuleAssembly() -> RecentWidgetModuleAssemblyProtocol {
        return RecentWidgetModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func bottomPanelProviderAssembly() -> HomeBottomPanelProviderAssemblyProtocol {
        return HomeBottomPanelProviderAssembly(widgetsDI: self)
    }
    
    func bottomPanelModuleAssembly() -> HomeBottomPanelModuleAssemblyProtocol {
        return HomeBottomPanelModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
}
