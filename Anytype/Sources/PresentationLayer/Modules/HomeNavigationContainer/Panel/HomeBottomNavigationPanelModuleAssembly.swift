import Foundation
import SwiftUI
import Services

protocol HomeBottomNavigationPanelModuleAssemblyProtocol {
    @MainActor
    func make(countItems: Int, output: HomeBottomNavigationPanelModuleOutput?) -> AnyView
}

final class HomeBottomNavigationPanelModuleAssembly: HomeBottomNavigationPanelModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - HomeBottomNavigationPanelModuleAssemblyProtocol
    
    @MainActor
    func make(countItems: Int, output: HomeBottomNavigationPanelModuleOutput?) -> AnyView {
        return HomeBottomNavigationPanelView(
            countItems: countItems,
            model: HomeBottomNavigationPanelViewModel(
                activeWorkpaceStorage: self.serviceLocator.activeWorkspaceStorage(),
                subscriptionService: self.serviceLocator.singleObjectSubscriptionService(),
                dashboardService: self.serviceLocator.dashboardService(),
                output: output
            )
        ).eraseToAnyView()
    }
}
