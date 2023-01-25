import Foundation

protocol HomeBottomPanelProviderAssemblyProtocol: AnyObject {
    func make(stateManager: HomeWidgetsStateManagerProtocol) -> HomeWidgetProviderProtocol
}

final class HomeBottomPanelProviderAssembly: HomeBottomPanelProviderAssemblyProtocol {
    
    private let widgetsDI: WidgetsDIProtocol
    
    init(widgetsDI: WidgetsDIProtocol) {
        self.widgetsDI = widgetsDI
    }
    
    // MARK: - HomeBottomPanelProviderAssemblyProtocol
    
    func make(stateManager: HomeWidgetsStateManagerProtocol) -> HomeWidgetProviderProtocol {
        return HomeBottomPanelProvider(
            bottomPanelModuleAssembly: widgetsDI.bottomPanelModuleAssembly(),
            stateManager: stateManager
        )
    }
}
