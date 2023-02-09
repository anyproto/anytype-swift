import Foundation

protocol HomeBottomPanelProviderAssemblyProtocol: AnyObject {
    func make(stateManager: HomeWidgetsStateManagerProtocol) -> HomeSubmoduleProviderProtocol
}

final class HomeBottomPanelProviderAssembly: HomeBottomPanelProviderAssemblyProtocol {
    
    private let widgetsDI: WidgetsDIProtocol
    private weak var output: HomeBottomPanelModuleOutput?
    
    init(widgetsDI: WidgetsDIProtocol, output: HomeBottomPanelModuleOutput?) {
        self.widgetsDI = widgetsDI
        self.output = output
    }
    
    // MARK: - HomeBottomPanelProviderAssemblyProtocol
    
    func make(stateManager: HomeWidgetsStateManagerProtocol) -> HomeSubmoduleProviderProtocol {
        return HomeBottomPanelProvider(
            bottomPanelModuleAssembly: widgetsDI.bottomPanelModuleAssembly(),
            stateManager: stateManager,
            output: output
        )
    }
}
