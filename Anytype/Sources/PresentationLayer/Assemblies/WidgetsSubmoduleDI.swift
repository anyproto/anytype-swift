import Foundation

protocol WidgetsSubmoduleDIProtocol {
    func homeWidgetsRegistry(
        stateManager: HomeWidgetsStateManagerProtocol,
        widgetOutput: CommonWidgetModuleOutput?
    ) -> HomeWidgetsRegistryProtocol
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
}

final class WidgetsSubmoduleDI: WidgetsSubmoduleDIProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - WidgetsSubmoduleDIProtocol
    
    func homeWidgetsRegistry(
        stateManager: HomeWidgetsStateManagerProtocol,
        widgetOutput: CommonWidgetModuleOutput?
    ) -> HomeWidgetsRegistryProtocol {
        return HomeWidgetsRegistry(
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
            stateManager: stateManager
        )
    }
    
    // MARK: - List
    
    func listWidgetModuleAssembly() -> ListWidgetModuleAssemblyProtocol {
        return ListWidgetModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func setListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return SetListWidgetModuleAssembly(serviceLocator: serviceLocator, widgetsSubmoduleDI: self)
    }
    
    func favoriteListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return FavoriteListWidgetModuleAssembly(widgetsSubmoduleDI: self)
    }
    
    func recentEditListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return RecentListWidgetModuleAssembly(type: .recentEdit, widgetsSubmoduleDI: self)
    }
    
    func recentOpenListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return RecentListWidgetModuleAssembly(type: .recentOpen, widgetsSubmoduleDI: self)
    }
    
    func setsListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return SetsListWidgetModuleAssembly(serviceLocator: serviceLocator, widgetsSubmoduleDI: self)
    }
    
    func collectionsListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return CollectionsListWidgetModuleAssembly(widgetsSubmoduleDI: self)
    }
    
    // MARK: - CompactList
    
    func setCompactListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return SetCompactListWidgetModuleAssembly(serviceLocator: serviceLocator, widgetsSubmoduleDI: self)
    }
    
    func favoriteCompactListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return FavoriteCompactListWidgetModuleAssembly(widgetsSubmoduleDI: self)
    }
    
    func recentEditCompactListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return RecentCompactListWidgetModuleAssembly(type: .recentEdit, widgetsSubmoduleDI: self)
    }
    
    func recentOpenCompactListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return RecentCompactListWidgetModuleAssembly(type: .recentOpen, widgetsSubmoduleDI: self)
    }
    
    func setsCompactListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return SetsCompactListWidgetModuleAssembly(widgetsSubmoduleDI: self)
    }
    
    func collectionsCompactListWidgetModuleAssembly() -> HomeWidgetCommonAssemblyProtocol {
        return CollectionsCompactListWidgetModuleAssembly(widgetsSubmoduleDI: self)
    }
}
