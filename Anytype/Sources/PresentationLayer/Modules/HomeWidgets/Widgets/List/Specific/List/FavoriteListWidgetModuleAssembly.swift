import Foundation
import SwiftUI

final class FavoriteListWidgetModuleAssembly: HomeWidgetCommonAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol
    
    init(serviceLocator: ServiceLocator, widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol) {
        self.serviceLocator = serviceLocator
        self.widgetsSubmoduleDI = widgetsSubmoduleDI
    }
    
    // MARK: - HomeWidgetCommonAssemblyProtocol
    
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        output: CommonWidgetModuleOutput?
    ) -> AnyView {
        
        let model = FavoriteWidgetInternalViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            favoriteSubscriptionService: serviceLocator.favoriteSubscriptionService(),
            activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage(),
            documentService: serviceLocator.documentService(),
            defaultObjectService: serviceLocator.defaultObjectCreationService(),
            objectActionsService: serviceLocator.objectActionsService(),
            output: output
        )
     
        return widgetsSubmoduleDI.listWidgetModuleAssembly().make(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            style: .list,
            stateManager: stateManager,
            internalModel: model,
            output: output
        )
    }
}
