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
    func setsWidgetModuleAssembly() -> SetsWidgetModuleAssemblyProtocol
    func linkWidgetModuleAssembly() -> LinkWidgetModuleAssemblyProtocol
    func binLinkWidgetModuleAssembly() -> BinLinkWidgetModuleAssemblyProtocol
    func bottomPanelProviderAssembly(output: HomeBottomPanelModuleOutput?) -> HomeBottomPanelProviderAssemblyProtocol
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
            treeWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: objectTreeWidgetModuleAssembly(),
                output: widgetOutput
            ),
            setWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: setWidgetModuleAssembly(),
                output: widgetOutput
            ),
            favoriteWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: favoriteWidgetModuleAssembly(),
                output: widgetOutput
            ),
            recentWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: recentWidgetModuleAssembly(),
                output: widgetOutput
            ),
            setsWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: setsWidgetModuleAssembly(),
                output: widgetOutput
            ),
            linkWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: linkWidgetModuleAssembly(),
                output: widgetOutput
            ),
            binLinkWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: binLinkWidgetModuleAssembly(),
                output: widgetOutput
            ),
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
    
    func setsWidgetModuleAssembly() -> SetsWidgetModuleAssemblyProtocol {
        return SetsWidgetModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func linkWidgetModuleAssembly() -> LinkWidgetModuleAssemblyProtocol {
        return LinkWidgetModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func binLinkWidgetModuleAssembly() -> BinLinkWidgetModuleAssemblyProtocol {
        return BinLinkWidgetModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func bottomPanelProviderAssembly(output: HomeBottomPanelModuleOutput?) -> HomeBottomPanelProviderAssemblyProtocol {
        return HomeBottomPanelProviderAssembly(widgetsDI: self, output: output)
    }
    
    func bottomPanelModuleAssembly() -> HomeBottomPanelModuleAssemblyProtocol {
        return HomeBottomPanelModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
}
