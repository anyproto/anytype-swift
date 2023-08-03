import Foundation
import SwiftUI
import Services

final class HomeBottomPanelProvider: HomeSubmoduleProviderProtocol {
    
    private let info: AccountInfo
    private let bottomPanelModuleAssembly: HomeBottomPanelModuleAssemblyProtocol
    private let stateManager: HomeWidgetsStateManagerProtocol
    private weak var output: HomeBottomPanelModuleOutput?
    
    init(
        info: AccountInfo,
        bottomPanelModuleAssembly: HomeBottomPanelModuleAssemblyProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        output: HomeBottomPanelModuleOutput?
    ) {
        self.info = info
        self.bottomPanelModuleAssembly = bottomPanelModuleAssembly
        self.stateManager = stateManager
        self.output = output
    }
    
    // MARK: - HomeSubmoduleProviderProtocol
    
    @MainActor
    lazy var view: AnyView = {
        return bottomPanelModuleAssembly.make(info: info, stateManager: stateManager, output: output)
    }()
    
    lazy var componentId: String = {
        return UUID().uuidString
    }()
}
