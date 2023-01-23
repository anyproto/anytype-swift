import Foundation
import SwiftUI

protocol RecentWidgetModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(widgetBlockId: String, widgetObject: HomeWidgetsObjectProtocol, output: CommonWidgetModuleOutput?) -> AnyView
}

final class RecentWidgetModuleAssembly: RecentWidgetModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - RecentWidgetModuleAssemblyProtocol
    
    @MainActor
    func make(widgetBlockId: String, widgetObject: HomeWidgetsObjectProtocol, output: CommonWidgetModuleOutput?) -> AnyView {
        
        let model = RecentWidgetViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            recentSubscriptionService: serviceLocator.recentSubscriptionService(),
            output: output
        )
        return ListWidgetView(model: model).eraseToAnyView()
    }
}
