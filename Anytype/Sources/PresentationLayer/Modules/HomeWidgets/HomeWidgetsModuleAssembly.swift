import Foundation
import SwiftUI

@MainActor
protocol HomeWidgetsModuleAssemblyProtocol {
    func make(widgetObjectId: String, output: HomeWidgetsModuleOutput) -> AnyView
}

@MainActor
final class HomeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol {
    
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(uiHelpersDI: UIHelpersDIProtocol) {
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - HomeWidgetsModuleAssemblyProtocol
    
    func make(widgetObjectId: String, output: HomeWidgetsModuleOutput) -> AnyView {
        let model = HomeWidgetsViewModel(
            widgeetObjectId: widgetObjectId,
            output: output,
            navigationContext: uiHelpersDI.commonNavigationContext
        )
        let view = HomeWidgetsView(model: model)
        return view.eraseToAnyView()
    }
}
