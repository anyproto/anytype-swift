import Foundation

@MainActor
final class ObjectTreeWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - HomeWidgetProviderAssemblyProtocol
    
    func make(widgetBlockId: String, widgetObject: HomeWidgetsObjectProtocol) -> HomeWidgetProviderProtocol {
        return ObjectTreeWidgetProvider(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            objectDetailsStorage: serviceLocator.objectDetailsStorage()
        )
    }
}
