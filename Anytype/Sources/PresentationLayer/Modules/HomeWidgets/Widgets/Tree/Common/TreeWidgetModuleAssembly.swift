import Foundation
import SwiftUI

protocol TreeWidgetModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        internalModel: WidgetInternalViewModelProtocol,
        output: CommonWidgetModuleOutput?
    ) -> AnyView
}

final class TreeWidgetModuleAssembly: TreeWidgetModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - TreeWidgetModuleAssemblyProtocol
    
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        internalModel: WidgetInternalViewModelProtocol,
        output: CommonWidgetModuleOutput?
    ) -> AnyView {
        
        let contentModel = TreeWidgetViewModel(
            widgetBlockId: widgetBlockId,
            internalModel: internalModel,
            subscriptionManager: serviceLocator.treeSubscriptionManager(),
            output: output
        )
        let contentView = TreeWidgetView(model: contentModel)
        
        let containerModel = WidgetContainerViewModel(
            serviceLocator: serviceLocator,
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
