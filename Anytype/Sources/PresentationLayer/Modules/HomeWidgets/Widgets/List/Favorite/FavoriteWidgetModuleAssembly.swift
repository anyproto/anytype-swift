import Foundation
import SwiftUI

protocol FavoriteWidgetModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(widgetBlockId: String, widgetObject: HomeWidgetsObjectProtocol, output: CommonWidgetModuleOutput?) -> AnyView
}

final class FavoriteWidgetModuleAssembly: FavoriteWidgetModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - FavoriteWidgetModuleAssemblyProtocol
    
    @MainActor
    func make(widgetBlockId: String, widgetObject: HomeWidgetsObjectProtocol, output: CommonWidgetModuleOutput?) -> AnyView {
        
        let model = FavoriteWidgetViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            accountManager: serviceLocator.accountManager(),
            favoriteSubscriptionService: serviceLocator.favoriteSubscriptionService(),
            output: output
        )
        return ListWidgetView(model: model).eraseToAnyView()
    }
}
