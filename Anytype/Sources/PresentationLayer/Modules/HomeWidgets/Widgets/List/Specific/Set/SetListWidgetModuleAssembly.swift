import Foundation
import SwiftUI

final class SetListWidgetModuleAssembly: HomeWidgetCommonAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - HomeWidgetCommonAssemblyProtocol
    
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        output: CommonWidgetModuleOutput?
    ) -> AnyView {
        
        let contentModel = SetListWidgetViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            relationDetailsStorage: serviceLocator.relationDetailsStorage(),
            subscriptionService: serviceLocator.subscriptionService(),
            setSubscriptionDataBuilder: SetSubscriptionDataBuilder(
                accountManager: serviceLocator.accountManager()
            ),
            documentService: serviceLocator.documentService(),
            objectDetailsStorage: serviceLocator.objectDetailsStorage(),
            output: output
        )
        let contentView = ListWidgetView(model: contentModel)
        
        let containerModel = WidgetContainerViewModel(
            serviceLocator: serviceLocator,
            uiHelpersDI: uiHelpersDI,
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            stateManager: stateManager,
            contentModel: contentModel,
            output: output
        )
        let containterView = WidgetContainerView(
            model: containerModel,
            contentModel: contentModel,
            content: contentView
        )
        return containterView.eraseToAnyView()
    }
}
