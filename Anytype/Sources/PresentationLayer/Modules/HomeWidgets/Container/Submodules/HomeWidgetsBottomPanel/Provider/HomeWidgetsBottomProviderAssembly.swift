import Foundation

protocol HomeWidgetsBottomProviderAssemblyProtocol: AnyObject {
    func make() -> HomeWidgetProviderProtocol
}

final class HomeWidgetsBottomProviderAssembly: HomeWidgetsBottomProviderAssemblyProtocol {
    
    private let widgetsDI: WidgetsDIProtocol
    
    init(widgetsDI: WidgetsDIProtocol) {
        self.widgetsDI = widgetsDI
    }
    
    // MARK: - HomeWidgetProviderAssemblyProtocol
    
    func make() -> HomeWidgetProviderProtocol {
        return HomeWidgetsBottomProvider(bottomModuleAssembly: widgetsDI.bottomModuleAssembly())
    }
}
