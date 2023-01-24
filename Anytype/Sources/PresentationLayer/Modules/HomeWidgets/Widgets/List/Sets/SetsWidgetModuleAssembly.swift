import Foundation
import SwiftUI

protocol SetsWidgetModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(widgetBlockId: String, widgetObject: HomeWidgetsObjectProtocol, output: CommonWidgetModuleOutput?) -> AnyView
}

final class SetsWidgetModuleAssembly: SetsWidgetModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - SetsWidgetModuleAssemblyProtocol
    
    @MainActor
    func make(widgetBlockId: String, widgetObject: HomeWidgetsObjectProtocol, output: CommonWidgetModuleOutput?) -> AnyView {
        
        let model = SetsWidgetViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            setsSubscriptionService: serviceLocator.setsSubscriptionService(),
            output: output
        )
        return ListWidgetView(model: model).eraseToAnyView()
    }
}
