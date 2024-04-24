import Foundation
import SwiftUI
import Services

protocol HomeBottomNavigationPanelModuleAssemblyProtocol {
    @MainActor
    func make(homePath: HomePath, info: AccountInfo, output: HomeBottomNavigationPanelModuleOutput?) -> AnyView
}

final class HomeBottomNavigationPanelModuleAssembly: HomeBottomNavigationPanelModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - HomeBottomNavigationPanelModuleAssemblyProtocol
    
    @MainActor
    func make(homePath: HomePath, info: AccountInfo, output: HomeBottomNavigationPanelModuleOutput?) -> AnyView {
        return HomeBottomNavigationPanelView(
            homePath: homePath,
            model: HomeBottomNavigationPanelViewModel(
                info: info,
                output: output
            )
        )
        .id(info.accountSpaceId)
        .eraseToAnyView()
    }
}
