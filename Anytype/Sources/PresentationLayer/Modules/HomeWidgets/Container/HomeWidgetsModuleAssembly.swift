import Foundation
import SwiftUI

protocol HomeWidgetsModuleAssemblyProtocol {
    @MainActor
    func make(
        widgetObjectId: String,
        output: HomeWidgetsModuleOutput,
        widgetOutput: CommonWidgetModuleOutput?,
        bottomPanelOutput: HomeBottomPanelModuleOutput?
    ) -> AnyView
}

final class HomeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    private let widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol, widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
        self.widgetsSubmoduleDI = widgetsSubmoduleDI
    }
    
    // MARK: - HomeWidgetsModuleAssemblyProtocol
    @MainActor
    func make(
        widgetObjectId: String,
        output: HomeWidgetsModuleOutput,
        widgetOutput: CommonWidgetModuleOutput?,
        bottomPanelOutput: HomeBottomPanelModuleOutput?
    ) -> AnyView {
        
        let stateManager = HomeWidgetsStateManager()
        let recentStateManagerProtocol = HomeWidgetsRecentStateManager(
            loginStateService: serviceLocator.loginStateService(),
            expandedService: serviceLocator.blockWidgetExpandedService()
        )
        
        let model = HomeWidgetsViewModel(
            widgetObjectId: widgetObjectId,
            registry: widgetsSubmoduleDI.homeWidgetsRegistry(stateManager: stateManager, widgetOutput: widgetOutput),
            blockWidgetService: serviceLocator.blockWidgetService(),
            bottomPanelProviderAssembly: widgetsSubmoduleDI.bottomPanelProviderAssembly(output: bottomPanelOutput),
            stateManager: stateManager,
            objectActionService: serviceLocator.objectActionsService(),
            recentStateManagerProtocol: recentStateManagerProtocol,
            documentService: serviceLocator.documentService(),
            workspaceService: serviceLocator.workspaceService(),
            workspacesStorage: serviceLocator.workspaceStorage(),
            output: output
        )
        let view = HomeWidgetsView(model: model)
        return view.eraseToAnyView()
    }
}
