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
    
    private let widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol
    
    init(widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol) {
        self.widgetsSubmoduleDI = widgetsSubmoduleDI
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
            registry: widgetsSubmoduleDI.homeWidgetsRegistry(stateManager: stateManager, widgetOutput: widgetOutput),
            stateManager: stateManager,
            recentStateManagerProtocol: recentStateManagerProtocol,
            output: output
        )
    }
}
