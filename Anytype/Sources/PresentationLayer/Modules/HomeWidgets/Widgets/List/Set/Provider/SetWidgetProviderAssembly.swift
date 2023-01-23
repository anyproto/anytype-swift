import Foundation

final class SetWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol {
    
    private let widgetsDI: WidgetsDIProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    init(widgetsDI: WidgetsDIProtocol, output: CommonWidgetModuleOutput?) {
        self.widgetsDI = widgetsDI
        self.output = output
    }
    
    // MARK: - HomeWidgetProviderAssemblyProtocol
    
    func make(widgetBlockId: String, widgetObject: HomeWidgetsObjectProtocol) -> HomeWidgetProviderProtocol {
        return SetWidgetProvider(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            setWidgetModuleAssembly: widgetsDI.setWidgetModuleAssembly(),
            output: output
        )
    }
}
