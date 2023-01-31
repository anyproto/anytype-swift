import Foundation
import SwiftUI

protocol FavoriteWidgetModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: HomeWidgetsObjectProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        output: FavoriteWidgetModuleOutput?
    ) -> AnyView
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
    func make(
        widgetBlockId: String,
        widgetObject: HomeWidgetsObjectProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        output: FavoriteWidgetModuleOutput?
    ) -> AnyView {
        
        let contentModel = FavoriteWidgetViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            accountManager: serviceLocator.accountManager(),
            favoriteSubscriptionService: serviceLocator.favoriteSubscriptionService(),
            output: output
        )
        let contentView = ListWidgetView(model: contentModel)
        
        let containerModel = WidgetContainerViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            blockWidgetService: serviceLocator.blockWidgetService(),
            stateManager: stateManager
        )
        let containterView = WidgetContainerView(
            model: containerModel,
            contentModel: contentModel,
            content: contentView
        )
        return containterView.eraseToAnyView()
    }
}
