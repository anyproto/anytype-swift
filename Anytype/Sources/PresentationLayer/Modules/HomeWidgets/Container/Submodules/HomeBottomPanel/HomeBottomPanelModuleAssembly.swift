import Foundation
import SwiftUI

protocol HomeBottomPanelModuleAssemblyProtocol {
    @MainActor
    func make() -> AnyView
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
    func make() -> AnyView {
        let model = HomeBottomPanelViewModel(
            toastPresenter: uiHelpersDI.toastPresenter,
            accountManager: serviceLocator.accountManager(),
            subscriptionService: serviceLocator.subscriptionService(),
            subscriotionBuilder: HomeBottomPanelSubscriptionDataBuilder()
        )
        return HomeBottomPanelView(model: model).eraseToAnyView()
    }
}
