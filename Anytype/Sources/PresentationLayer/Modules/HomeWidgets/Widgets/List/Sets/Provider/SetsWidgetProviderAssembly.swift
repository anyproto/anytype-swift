import Foundation

final class SetsWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol {
    
    private let widgetsDI: WidgetsDIProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    init(widgetsDI: WidgetsDIProtocol, output: CommonWidgetModuleOutput?) {
        self.widgetsDI = widgetsDI
        self.output = output
    }
    
    // MARK: - HomeWidgetProviderAssemblyProtocol
    
    func make(
        widgetBlockId: String,
        widgetObject: HomeWidgetsObjectProtocol,
        stateManager: HomeWidgetsStateManagerProtocol
    ) -> HomeWidgetProviderProtocol {
        return SetsWidgetProvider(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            setsWidgetModuleAssembly: widgetsDI.setsWidgetModuleAssembly(),
            stateManager: stateManager,
            output: output
        )
    }
}
