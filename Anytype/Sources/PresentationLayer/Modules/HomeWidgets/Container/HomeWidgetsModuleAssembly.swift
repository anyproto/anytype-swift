import Foundation
import SwiftUI
import Services

protocol HomeWidgetsModuleAssemblyProtocol {
    @MainActor
    func make(
        info: AccountInfo,
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
        info: AccountInfo,
        output: HomeWidgetsModuleOutput,
        widgetOutput: CommonWidgetModuleOutput?,
        bottomPanelOutput: HomeBottomPanelModuleOutput?
    ) -> AnyView {
        let view = HomeWidgetsView(
            model: self.modelProvider(
                info: info,
                output: output,
                widgetOutput: widgetOutput,
                bottomPanelOutput: bottomPanelOutput
            )
        )
        return view.id(info.widgetsId).eraseToAnyView()
    }
    
    // MARK: - Private
    
    @MainActor
    private func modelProvider(
        info: AccountInfo,
        output: HomeWidgetsModuleOutput,
        widgetOutput: CommonWidgetModuleOutput?,
        bottomPanelOutput: HomeBottomPanelModuleOutput?
    ) -> HomeWidgetsViewModel {
        let stateManager = HomeWidgetsStateManager()
        let recentStateManagerProtocol = HomeWidgetsRecentStateManager(
            loginStateService: serviceLocator.loginStateService(),
            expandedService: serviceLocator.blockWidgetExpandedService()
        )
        
        return HomeWidgetsViewModel(
            info: info,
            registry: widgetsSubmoduleDI.homeWidgetsRegistry(stateManager: stateManager, widgetOutput: widgetOutput),
            blockWidgetService: serviceLocator.blockWidgetService(),
            bottomPanelProviderAssembly: widgetsSubmoduleDI.bottomPanelProviderAssembly(output: bottomPanelOutput),
            stateManager: stateManager,
            objectActionService: serviceLocator.objectActionsService(),
            recentStateManagerProtocol: recentStateManagerProtocol,
            documentService: serviceLocator.documentService(),
            activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage(),
            workspaceService: serviceLocator.workspaceService(),
            workspacesStorage: serviceLocator.workspaceStorage(),
            output: output
        )
    }
}
