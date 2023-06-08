import Foundation

protocol HomeBottomPanelProviderAssemblyProtocol: AnyObject {
    func make(stateManager: HomeWidgetsStateManagerProtocol) -> HomeSubmoduleProviderProtocol
}

final class HomeBottomPanelProviderAssembly: HomeBottomPanelProviderAssemblyProtocol {
    
    private let widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol
    private weak var output: HomeBottomPanelModuleOutput?
    
    init(widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol, output: HomeBottomPanelModuleOutput?) {
        self.widgetsSubmoduleDI = widgetsSubmoduleDI
        self.output = output
    }
    
    // MARK: - HomeBottomPanelProviderAssemblyProtocol
    
    func make(stateManager: HomeWidgetsStateManagerProtocol) -> HomeSubmoduleProviderProtocol {
        return HomeBottomPanelProvider(
            bottomPanelModuleAssembly: widgetsSubmoduleDI.bottomPanelModuleAssembly(),
            stateManager: stateManager,
            output: output
        )
    }
}
