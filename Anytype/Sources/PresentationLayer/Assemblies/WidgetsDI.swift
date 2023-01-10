import Foundation

protocol WidgetsDIProtocol {
    func homeWidgetsRegistry() -> HomeWidgetsRegistryProtocol
    func objectTreeWidgetModuleAssembly() -> ObjectTreeWidgetModuleAssemblyProtocol
    func bottomProviderAssembly() -> HomeWidgetsBottomProviderAssemblyProtocol
    func bottomModuleAssembly() -> HomeWidgetsBottomModuleAssemblyProtocol
}

final class WidgetsDI: WidgetsDIProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - WidgetsDIProtocol
    
    func homeWidgetsRegistry() -> HomeWidgetsRegistryProtocol {
        return HomeWidgetsRegistry(
            treeWidgetProviderAssembly: ObjectTreeWidgetProviderAssembly(widgetsDI: self),
            objectDetailsStorage: serviceLocator.objectDetailsStorage()
        )
    }
    
    func objectTreeWidgetModuleAssembly() -> ObjectTreeWidgetModuleAssemblyProtocol {
        return ObjectTreeWidgetModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func bottomProviderAssembly() -> HomeWidgetsBottomProviderAssemblyProtocol {
        return HomeWidgetsBottomProviderAssembly(widgetsDI: self)
    }
    
    func bottomModuleAssembly() -> HomeWidgetsBottomModuleAssemblyProtocol {
        return HomeWidgetsBottomModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
}
