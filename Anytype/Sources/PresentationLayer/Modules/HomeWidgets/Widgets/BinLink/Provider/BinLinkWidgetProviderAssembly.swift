import Foundation

final class BinLinkWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol {
    
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
        return BinLinkWidgetProvider(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            linkWidgetModuleAssembly: widgetsDI.binLinkWidgetModuleAssembly(),
            stateManager: stateManager,
            output: output
        )
    }
}
