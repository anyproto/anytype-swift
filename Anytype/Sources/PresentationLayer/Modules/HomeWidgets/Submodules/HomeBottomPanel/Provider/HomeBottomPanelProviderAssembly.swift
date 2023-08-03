import Foundation
import Services

protocol HomeBottomPanelProviderAssemblyProtocol: AnyObject {
    func make(info: AccountInfo, stateManager: HomeWidgetsStateManagerProtocol) -> HomeSubmoduleProviderProtocol
}

final class HomeBottomPanelProviderAssembly: HomeBottomPanelProviderAssemblyProtocol {
    
    private let widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol
    private weak var output: HomeBottomPanelModuleOutput?
    
    init(widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol, output: HomeBottomPanelModuleOutput?) {
        self.widgetsSubmoduleDI = widgetsSubmoduleDI
        self.output = output
    }
    
    // MARK: - HomeBottomPanelProviderAssemblyProtocol
    
    func make(info: AccountInfo, stateManager: HomeWidgetsStateManagerProtocol) -> HomeSubmoduleProviderProtocol {
        return HomeBottomPanelProvider(
            info: info,
            bottomPanelModuleAssembly: widgetsSubmoduleDI.bottomPanelModuleAssembly(),
            stateManager: stateManager,
            output: output
        )
    }
}
