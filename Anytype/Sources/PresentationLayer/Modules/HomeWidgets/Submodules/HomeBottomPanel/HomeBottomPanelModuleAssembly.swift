import Foundation
import SwiftUI

protocol HomeBottomPanelModuleAssemblyProtocol {
    @MainActor
    func make(stateManager: HomeWidgetsStateManagerProtocol, output: HomeBottomPanelModuleOutput?) -> AnyView
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
    func make(stateManager: HomeWidgetsStateManagerProtocol, output: HomeBottomPanelModuleOutput?) -> AnyView {
        let model = HomeBottomPanelViewModel(
            toastPresenter: uiHelpersDI.toastPresenter(),
            accountManager: serviceLocator.accountManager(),
            subscriptionService: serviceLocator.subscriptionService(),
            subscriotionBuilder: HomeBottomPanelSubscriptionDataBuilder(),
            stateManager: stateManager,
            dashboardService: serviceLocator.dashboardService(),
            output: output
        )
        return HomeBottomPanelView(model: model).eraseToAnyView()
    }
}
