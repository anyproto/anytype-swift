import Foundation

final class FavoriteWidgetProviderAssembly: HomeWidgetProviderAssemblyProtocol {
    
    private let widgetsDI: WidgetsDIProtocol
    private weak var output: FavoriteWidgetModuleOutput?
    
    init(widgetsDI: WidgetsDIProtocol, output: FavoriteWidgetModuleOutput?) {
        self.widgetsDI = widgetsDI
        self.output = output
    }
    
    // MARK: - HomeWidgetProviderAssemblyProtocol
    
    func make(
        widgetBlockId: String,
        widgetObject: HomeWidgetsObjectProtocol,
        stateManager: HomeWidgetsStateManagerProtocol
    ) -> HomeWidgetProviderProtocol {
        return FavoriteWidgetProvider(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            favoriteWidgetModuleAssembly: widgetsDI.favoriteWidgetModuleAssembly(),
            stateManager: stateManager,
            output: output
        )
    }
}
