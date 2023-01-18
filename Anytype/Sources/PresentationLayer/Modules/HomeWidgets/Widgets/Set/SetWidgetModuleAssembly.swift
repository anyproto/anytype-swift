import Foundation
import SwiftUI

protocol SetWidgetModuleAssemblyProtocol {
    @MainActor
    func make(widgetBlockId: String, widgetObject: HomeWidgetsObjectProtocol, output: SetWidgetModuleOutput?) -> AnyView
}

final class SetWidgetModuleAssembly: SetWidgetModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - SetWidgetModuleAssemblyProtocol
    
    @MainActor
    func make(widgetBlockId: String, widgetObject: HomeWidgetsObjectProtocol, output: SetWidgetModuleOutput?) -> AnyView {
        
        let model = SetWidgetViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            objectDetailsStorage: serviceLocator.objectDetailsStorage(),
            blockWidgetService: serviceLocator.blockWidgetService(),
            output: output
        )
        return SetWidgetView(model: model).eraseToAnyView()
    }
}
