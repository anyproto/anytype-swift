import Foundation
import SwiftUI
import Services

protocol HomeBottomPanelModuleAssemblyProtocol {
    @MainActor
    func make(info: AccountInfo, stateManager: HomeWidgetsStateManagerProtocol, output: HomeBottomPanelModuleOutput?) -> AnyView
}

final class HomeBottomPanelModuleAssembly: HomeBottomPanelModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - HomeBottomPanelModuleAssemblyProtocol
    
    @MainActor
    func make(info: AccountInfo, stateManager: HomeWidgetsStateManagerProtocol, output: HomeBottomPanelModuleOutput?) -> AnyView {
        return HomeBottomPanelView(model: HomeBottomPanelViewModel(
            info: info,
            subscriptionService: self.serviceLocator.singleObjectSubscriptionService(),
            stateManager: stateManager,
            dashboardService: self.serviceLocator.dashboardService(),
            output: output
        )).eraseToAnyView()
    }
}
