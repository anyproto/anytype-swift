import Foundation
import SwiftUI
import Services

protocol HomeWidgetsModuleAssemblyProtocol {
    @MainActor
    func make(
        info: AccountInfo,
        output: HomeWidgetsModuleOutput,
        widgetOutput: CommonWidgetModuleOutput?
    ) -> AnyView
}

final class HomeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol {
    
    init() {
    }
    
    // MARK: - HomeWidgetsModuleAssemblyProtocol
    
    @MainActor
    func make(
        info: AccountInfo,
        output: HomeWidgetsModuleOutput,
        widgetOutput: CommonWidgetModuleOutput?
    ) -> AnyView {
        let view = HomeWidgetsView(
            model: self.modelProvider(
                info: info,
                output: output,
                widgetOutput: widgetOutput
            )
        )
        return view.id(info.widgetsId).eraseToAnyView()
    }
    
    // MARK: - Private
    
    @MainActor
    private func modelProvider(
        info: AccountInfo,
        output: HomeWidgetsModuleOutput,
        widgetOutput: CommonWidgetModuleOutput?
    ) -> HomeWidgetsViewModel {
        let stateManager = HomeWidgetsStateManager()
        let recentStateManagerProtocol = HomeWidgetsRecentStateManager()
        
        return HomeWidgetsViewModel(
            info: info,
            stateManager: stateManager,
            recentStateManagerProtocol: recentStateManagerProtocol,
            output: output
        )
    }
}
