import Foundation

final class RecentWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol {
    
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
        return RecentWidgetProvider(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            recentWidgetModuleAssembly: widgetsDI.recentWidgetModuleAssembly(),
            stateManager: stateManager,
            output: output
        )
    }
}
