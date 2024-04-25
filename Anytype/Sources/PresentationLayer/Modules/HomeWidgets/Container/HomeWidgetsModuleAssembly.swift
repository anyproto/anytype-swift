import Foundation
import SwiftUI
import Services

protocol HomeWidgetsModuleAssemblyProtocol {
    @MainActor
    func make(
        info: AccountInfo,
        output: HomeWidgetsModuleOutput,
        widgetOutput: CommonWidgetModuleOutput?
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
        widgetOutput: CommonWidgetModuleOutput?
    ) -> AnyView {
        let view = HomeWidgetsView(
            model: self.modelProvider(
                info: info,
                output: output,
                widgetOutput: widgetOutput
            )
        )
        return view.id(info.widgetsId).eraseToAnyView()
    }
    
    // MARK: - Private
    
    @MainActor
    private func modelProvider(
        info: AccountInfo,
        output: HomeWidgetsModuleOutput,
        widgetOutput: CommonWidgetModuleOutput?
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
            stateManager: stateManager,
            objectActionService: serviceLocator.objectActionsService(),
            recentStateManagerProtocol: recentStateManagerProtocol,
            activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage(), 
            documentService: serviceLocator.documentService(),
            accountParticipantStorage: serviceLocator.accountParticipantStorage(),
            output: output
        )
    }
}
