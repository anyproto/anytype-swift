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
            stateManager: stateManager,
            output: output
        )).eraseToAnyView()
    }
}
