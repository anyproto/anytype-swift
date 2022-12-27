import Foundation
import SwiftUI

@MainActor
protocol HomeWidgetsModuleAssemblyProtocol {
    func make(widgetObjectId: String, output: HomeWidgetsModuleOutput) -> AnyView
}

@MainActor
final class HomeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - HomeWidgetsModuleAssemblyProtocol
    
    func make(widgetObjectId: String, output: HomeWidgetsModuleOutput) -> AnyView {
        let model = HomeWidgetsViewModel(
            widgetObject: HomeWidgetsObject(
                objectId: widgetObjectId,
                objectDetailsStorage: serviceLocator.objectDetailsStorage()
            ),
            registry: serviceLocator.homeWidgetsRegistry(),
            blockWidgetService: serviceLocator.blockWidgetService(),
            output: output
        )
        let view = HomeWidgetsView(model: model)
        return view.eraseToAnyView()
    }
}
