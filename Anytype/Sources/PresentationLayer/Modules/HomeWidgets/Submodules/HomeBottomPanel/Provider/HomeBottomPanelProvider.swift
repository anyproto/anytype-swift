import Foundation
import SwiftUI

final class HomeBottomPanelProvider: HomeWidgetProviderProtocol {
    
    private let bottomPanelModuleAssembly: HomeBottomPanelModuleAssemblyProtocol
    private let stateManager: HomeWidgetsStateManagerProtocol
    
    init(
        bottomPanelModuleAssembly: HomeBottomPanelModuleAssemblyProtocol,
        stateManager: HomeWidgetsStateManagerProtocol
    ) {
        self.bottomPanelModuleAssembly = bottomPanelModuleAssembly
        self.stateManager = stateManager
    }
    
    // MARK: - HomeWidgetProviderProtocol
    
    @MainActor
    lazy var view: AnyView = {
        return bottomPanelModuleAssembly.make(stateManager: stateManager)
    }()
    
    lazy var componentId: String = {
        return UUID().uuidString
    }()
}
