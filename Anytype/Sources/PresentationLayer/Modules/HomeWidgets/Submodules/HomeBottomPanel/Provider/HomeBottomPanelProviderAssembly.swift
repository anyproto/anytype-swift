import Foundation

protocol HomeBottomPanelProviderAssemblyProtocol: AnyObject {
    func make() -> HomeWidgetProviderProtocol
}

final class HomeBottomPanelProviderAssembly: HomeBottomPanelProviderAssemblyProtocol {
    
    private let widgetsDI: WidgetsDIProtocol
    
    init(widgetsDI: WidgetsDIProtocol) {
        self.widgetsDI = widgetsDI
    }
    
    // MARK: - HomeBottomPanelProviderAssemblyProtocol
    
    func make() -> HomeWidgetProviderProtocol {
        return HomeBottomPanelProvider(bottomPanelModuleAssembly: widgetsDI.bottomPanelModuleAssembly())
    }
}
