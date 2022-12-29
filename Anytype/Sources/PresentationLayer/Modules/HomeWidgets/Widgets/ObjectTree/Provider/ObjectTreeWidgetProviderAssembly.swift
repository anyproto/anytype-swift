import Foundation

final class ObjectTreeWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol {
    
    private let widgetsDI: WidgetsDIProtocol
    
    init(widgetsDI: WidgetsDIProtocol) {
        self.widgetsDI = widgetsDI
    }
    
    // MARK: - HomeWidgetProviderAssemblyProtocol
    
    func make(widgetBlockId: String, widgetObject: HomeWidgetsObjectProtocol) -> HomeWidgetProviderProtocol {
        return ObjectTreeWidgetProvider(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            objectTreeWidgetModuleAssembly: widgetsDI.objectTreeWidgetModuleAssembly()
        )
    }
}
