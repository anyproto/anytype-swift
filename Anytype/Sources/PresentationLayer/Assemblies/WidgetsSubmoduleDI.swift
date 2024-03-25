import Foundation

protocol WidgetsSubmoduleDIProtocol {
    func homeWidgetsRegistry(
        stateManager: HomeWidgetsStateManagerProtocol,
        widgetOutput: CommonWidgetModuleOutput?
    ) -> HomeWidgetsRegistryProtocol
    // MARK: - Tree
    func treeWidgetModuleAssembly() -> TreeWidgetModuleAssemblyProtocol
    func objectTreeWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol
    func favoriteTreeWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol
    func recentEditTreeWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol
    func recentOpenTreeWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol
    // MARK: - List
    func listWidgetModuleAssembly() -> ListWidgetModuleAssemblyProtocol
    func setListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol
    func favoriteListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol
    func recentEditListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol
    func recentOpenListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol
    func setsListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol
    func collectionsListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol
    // MARK: - CompactList
    func setCompactListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol
    func favoriteCompactListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol
    func recentEditCompactListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol
    func recentOpenCompactListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol
    func setsCompactListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol
    func collectionsCompactListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol
    // MARK: - Link
    func linkWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol
    func binLinkWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol
    // MARK: - Bottom
    func bottomPanelProviderAssembly(output: HomeBottomPanelModuleOutput?) -> HomeBottomPanelProviderAssemblyProtocol
    func bottomPanelModuleAssembly() -> HomeBottomPanelModuleAssemblyProtocol
}

final class WidgetsSubmoduleDI: WidgetsSubmoduleDIProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - WidgetsSubmoduleDIProtocol
    
    func homeWidgetsRegistry(
        stateManager: HomeWidgetsStateManagerProtocol,
        widgetOutput: CommonWidgetModuleOutput?
    ) -> HomeWidgetsRegistryProtocol {
        return HomeWidgetsRegistry(
            objectTreeWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: objectTreeWidgetModuleAssembly(),
                output: widgetOutput
            ),
            favoriteTreeWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: favoriteTreeWidgetModuleAssembly(),
                output: widgetOutput
            ),
            recentEditTreeWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: recentEditTreeWidgetModuleAssembly(),
                output: widgetOutput
            ),
            recentOpenTreeWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: recentOpenTreeWidgetModuleAssembly(),
                output: widgetOutput
            ),
            setListWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: setListWidgetModuleAssembly(),
                output: widgetOutput
            ),
            favoriteListWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: favoriteListWidgetModuleAssembly(),
                output: widgetOutput
            ),
            recentEditListWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: recentEditListWidgetModuleAssembly(),
                output: widgetOutput
            ),
            recentOpenListWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: recentOpenListWidgetModuleAssembly(),
                output: widgetOutput
            ),
            setsListWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: setsListWidgetModuleAssembly(),
                output: widgetOutput
            ),
            collectionsListWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: collectionsListWidgetModuleAssembly(),
                output: widgetOutput
            ),
            setCompactListWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: setCompactListWidgetModuleAssembly(),
                output: widgetOutput
            ),
            favoriteCompactListWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: favoriteCompactListWidgetModuleAssembly(),
                output: widgetOutput
            ),
            recentEditCompactListWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: recentEditCompactListWidgetModuleAssembly(),
                output: widgetOutput
            ),
            recentOpenCompactListWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: recentOpenCompactListWidgetModuleAssembly(),
                output: widgetOutput
            ),
            setsCompactListWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: setsCompactListWidgetModuleAssembly(),
                output: widgetOutput
            ),
            collectionsCompactListWidgetProviderAssembly: HomeWidgetCommonProviderAssembly(
                widgetAssembly: collectionsCompactListWidgetModuleAssembly(),
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
            stateManager: stateManager
        )
    }
    
    // MARK: - Tree
    
    func treeWidgetModuleAssembly() -> TreeWidgetModuleAssemblyProtocol {
        return TreeWidgetModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func objectTreeWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return ObjectTreeWidgetModuleAssembly(serviceLocator: serviceLocator, widgetsSubmoduleDI: self)
    }
    
    func favoriteTreeWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return FavoriteTreeWidgetModuleAssembly(serviceLocator: serviceLocator, widgetsSubmoduleDI: self)
    }
    
    func recentEditTreeWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return RecentTreeWidgetModuleAssembly(type: .recentEdit, serviceLocator: serviceLocator, widgetsSubmoduleDI: self)
    }
    
    func recentOpenTreeWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return RecentTreeWidgetModuleAssembly(type: .recentOpen, serviceLocator: serviceLocator, widgetsSubmoduleDI: self)
    }
    
    // MARK: - List
    
    func listWidgetModuleAssembly() -> ListWidgetModuleAssemblyProtocol {
        return ListWidgetModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func setListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return SetListWidgetModuleAssembly(serviceLocator: serviceLocator, widgetsSubmoduleDI: self)
    }
    
    func favoriteListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return FavoriteListWidgetModuleAssembly(serviceLocator: serviceLocator, widgetsSubmoduleDI: self)
    }
    
    func recentEditListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return RecentListWidgetModuleAssembly(type: .recentEdit, serviceLocator: serviceLocator, widgetsSubmoduleDI: self)
    }
    
    func recentOpenListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return RecentListWidgetModuleAssembly(type: .recentOpen, serviceLocator: serviceLocator, widgetsSubmoduleDI: self)
    }
    
    func setsListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return SetsListWidgetModuleAssembly(serviceLocator: serviceLocator, widgetsSubmoduleDI: self)
    }
    
    func collectionsListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return CollectionsListWidgetModuleAssembly(serviceLocator: serviceLocator, widgetsSubmoduleDI: self)
    }
    
    // MARK: - CompactList
    
    func setCompactListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return SetCompactListWidgetModuleAssembly(serviceLocator: serviceLocator, widgetsSubmoduleDI: self)
    }
    
    func favoriteCompactListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return FavoriteCompactListWidgetModuleAssembly(serviceLocator: serviceLocator, widgetsSubmoduleDI: self)
    }
    
    func recentEditCompactListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return RecentCompactListWidgetModuleAssembly(type: .recentEdit, serviceLocator: serviceLocator, widgetsSubmoduleDI: self)
    }
    
    func recentOpenCompactListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return RecentCompactListWidgetModuleAssembly(type: .recentOpen, serviceLocator: serviceLocator, widgetsSubmoduleDI: self)
    }
    
    func setsCompactListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return SetsCompactListWidgetModuleAssembly(serviceLocator: serviceLocator, widgetsSubmoduleDI: self)
    }
    
    func collectionsCompactListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return CollectionsCompactListWidgetModuleAssembly(serviceLocator: serviceLocator, widgetsSubmoduleDI: self)
    }
    
    // MARK: - Link
    
    func linkWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return LinkWidgetModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func binLinkWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return BinLinkWidgetModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    // MARK: - Bottom
    
    func bottomPanelProviderAssembly(output: HomeBottomPanelModuleOutput?) -> HomeBottomPanelProviderAssemblyProtocol {
        return HomeBottomPanelProviderAssembly(widgetsSubmoduleDI: self, output: output)
    }
    
    func bottomPanelModuleAssembly() -> HomeBottomPanelModuleAssemblyProtocol {
        return HomeBottomPanelModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
}
