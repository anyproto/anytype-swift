import Foundation
import SwiftUI

protocol HomeWidgetsBottomModuleAssemblyProtocol {
    @MainActor
    func make() -> AnyView
}

final class HomeWidgetsBottomModuleAssembly: HomeWidgetsBottomModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - HomeWidgetsBottomModuleAssemblyProtocol
    
    @MainActor
    func make() -> AnyView {
        let model = HomeWidgetsBottomPanelViewModel(
            toastPresenter: uiHelpersDI.toastPresenter,
            accountManager: serviceLocator.accountManager(),
            subscriptionService: serviceLocator.subscriptionService()
        )
        return HomeWidgetsBottomPanelView(model: model).eraseToAnyView()
    }
}
