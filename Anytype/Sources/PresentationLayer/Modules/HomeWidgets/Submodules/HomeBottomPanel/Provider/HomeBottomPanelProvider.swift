import Foundation
import SwiftUI

final class HomeBottomPanelProvider: HomeWidgetProviderProtocol {
    
    private let bottomPanelModuleAssembly: HomeBottomPanelModuleAssemblyProtocol
    
    init(
        bottomPanelModuleAssembly: HomeBottomPanelModuleAssemblyProtocol
    ) {
        self.bottomPanelModuleAssembly = bottomPanelModuleAssembly
    }
    
    // MARK: - HomeWidgetProviderProtocol
    
    @MainActor
    lazy var view: AnyView = {
        return bottomPanelModuleAssembly.make()
    }()
    
    lazy var componentId: String = {
        return UUID().uuidString
    }()
}
