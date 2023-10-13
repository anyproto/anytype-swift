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
        let model = HomeBottomPanelViewModel(
            info: info,
            subscriptionService: serviceLocator.singleObjectSubscriptionService(),
            stateManager: stateManager,
            dashboardService: serviceLocator.dashboardService(),
            output: output
        )
        return HomeBottomPanelView(model: model).eraseToAnyView()
    }
}
