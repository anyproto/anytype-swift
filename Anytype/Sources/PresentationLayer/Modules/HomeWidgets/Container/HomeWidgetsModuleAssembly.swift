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
            registry: HomeWidgetsRegistry(),
            output: output
        )
        let view = HomeWidgetsView(model: model)
        return view.eraseToAnyView()
    }
}
