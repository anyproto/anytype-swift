import Foundation

final class SetWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol {
    
    private let widgetsDI: WidgetsDIProtocol
    private weak var output: SetWidgetModuleOutput?
    
    init(widgetsDI: WidgetsDIProtocol, output: SetWidgetModuleOutput?) {
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
