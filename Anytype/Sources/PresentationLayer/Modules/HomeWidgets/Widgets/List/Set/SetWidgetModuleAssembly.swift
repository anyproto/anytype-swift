import Foundation
import SwiftUI

protocol SetWidgetModuleAssemblyProtocol: HomeWidgetCommonAssemblyProtocol {}

final class SetWidgetModuleAssembly: SetWidgetModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - SetWidgetModuleAssemblyProtocol
    
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: HomeWidgetsObjectProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        output: CommonWidgetModuleOutput?
    ) -> AnyView {
        
        let contentModel = SetWidgetViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            relationDetailsStorage: serviceLocator.relationDetailsStorage(),
            subscriptionService: serviceLocator.subscriptionService(),
            setSubscriptionDataBuilder: SetSubscriptionDataBuilder(
                accountManager: serviceLocator.accountManager()
            ),
            output: output
        )
        let contentView = ListWidgetView(model: contentModel)
        
        let containerModel = WidgetContainerViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            blockWidgetService: serviceLocator.blockWidgetService(),
            stateManager: stateManager,
            blockWidgetExpandedService: serviceLocator.blockWidgetExpandedService()
        )
        let containterView = WidgetContainerView(
            model: containerModel,
            contentModel: contentModel,
            content: contentView
        )
        return containterView.eraseToAnyView()
    }
}
